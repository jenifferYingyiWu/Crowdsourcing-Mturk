classdef ActiveLearnerIWAL < ActiveLearnerBernoliSampling    
% This function is an implementation of Agnostic Avtive Learning Without
% Constraints, by Beygelzimer et al. NIPS 2010.
    
    properties (Constant)
        canConsumeExactBudget = false;
        scoresEachItemOnlyOnce = true;
        acronym = 'iwal2';
        requiredClassifierTypes = {};
    end
    
    properties
        deltaType = 'Rademacher-Bootstrap';
        C0details = [];
    end
    
    methods
        function obj = ActiveLearnerIWAL(crowdManager, learner, randStream, deltaType, C0details)
            obj = obj@ActiveLearnerBernoliSampling(crowdManager, learner, randStream);
            if exist('deltaType', 'var'); obj.deltaType = deltaType; end
            if ~obj.supportsDeltaType(obj.deltaType); error(['This delta type is currently not supported: ' obj.deltaType]); end 
            if exist('C0details', 'var'); obj.C0details = C0details; end
        end
        
        function samplingProbability = calculateScores(obj, trainWeights, trainData, trainLabel, testData)
            iwalTime=tic;

            nTest = size(testData,1);
            c1 = 5 + 2*2^0.5;
            c2 = 5;            

            [originalPredictedLabels, originalModel] = obj.learner.trainPredict(trainWeights, trainData, trainLabel, testData);
            oppositeLabels = 1-originalPredictedLabels;
            testWeights = ones(nTest)*10;
            h_k = zeros(nTest);
            h_k_prime = zeros(nTest);
            samplingProbability = zeros(nTest,1);

            Delta = obj.computeDelta(trainWeights, trainData, trainLabel);

            idontKnow   = 0;
            for i=1:nTest
                while obj.learner.trainPredict([trainWeights; testWeights(i)], [trainData; testData(i,:)], [trainLabel; oppositeLabels(i)], testData(i,:)) ~= oppositeLabels(i)
                    testWeights(i) = 10*testWeights(i); % is 10 too aggresive?
                    if testWeights(i)> 100000
                        idontKnow = 1; % I don't know why this can happen!
                        break;
                    end
                end
                h_k(i) =  binWeightedClassError(obj.learner.trainPredict(trainWeights, trainData, trainLabel, trainData), trainWeights, trainLabel); % we need to convert accuracy into error
                if ~idontKnow
                    h_k_prime(i) =  binWeightedClassError(obj.learner.trainPredict([trainWeights; testWeights(i)], [trainData; testData(i,:)], [trainLabel; oppositeLabels(i)], trainData), trainWeights, trainLabel);    
                else
                    h_k_prime(i) = 1; % just to get the label for this guy to be sure!
                end
                G_k = h_k_prime(i) - h_k(i);

                if isnan(Delta) || G_k <= sqrt(Delta) + Delta
                    samplingProbability(i) = 1;
                    answer = -1;
                elseif Delta==0
                    samplingProbability(i) = 0; 
                    fprintf(1, 'Strange: your Delta=0 which means all your bootstrapped classifiers have the same empirical loss as the original one!');
                    answer = -1;        
                else
                    syms s;
                    answer = solve((c1/sqrt(s) - c1 + 1)*sqrt(Delta) + (c2/s -c2 +1)*Delta == G_k, s);
                    answer = double(answer);
                    if 0<answer && answer<1
                        samplingProbability(i) = answer;
                    else
                        warning('We could not find an answer in (0,1) interval');
                        if answer<=0 % not sure what i should do! this is just a guess 
                            samplingProbability(i) = 0; % not sure what i should do! this is just a guess
                        else
                            samplingProbability(i) = 1; % not sure what i should do! this is just a guess
                        end
                    end
                end
                fprintf(1,'G_k=%f, sqrt(delta)+delta=%f, answer=%f\n', G_k, (sqrt(Delta) + Delta), answer);
            end
            %fprintf(1,'max fake weight=%d\n', max(max(testWeights)));
            
            elapsed = toc(iwalTime);
            fprintf(1,'iwalTime time=%f\n',elapsed);            
            
        end

    end

    methods (Static)
        function msg = desc
            msg = ['This function is an implementation of Agnostic Avtive Learning Without\n' ...
                   'Constraints, by Beygelzimer et al. NIPS 2010.'];
        end
    end
    
    methods (Hidden)
        function yes = supportsDeltaType(obj, deltaType)
            if strcmp(deltaType, 'VC-bounds') || strcmp(deltaType, 'Rademacher') || strcmp(deltaType, 'Rademacher-Bootstrap')
                yes = true;
            else
                yes = false;
            end

        end
        
        function Delta = computeDelta(obj, trainWeights, trainData, trainLabel)
            nTrain = size(trainData,1); nFeatures = size(trainData,2);

            k = nTrain+1;


            C0delta = getFieldValueOrDefault(obj.C0details, 'C0delta', 0.05); % delta means that with probability 1-delta we won't miss out the best hypthesis                
            if strcmp(obj.deltaType, 'VC-bounds')
                w = originalModel.w;
                effectiveStatisticalDimension = length(w) + 1; % if w includes the intercept, this should be length(w) + 0
                C0 = effectiveStatisticalDimension / C0delta;
                Delta = C0*log(k) / (k-1);
            elseif strcmp(obj.deltaType, 'Rademacher')
                C0type = getFieldValueOrDefault(obj.C0details, 'C0type', 'Unknown');
                C0normalized = getFieldValueOrDefault(obj.C0details, 'C0normalized', 'Unknown');

                if strcmp(C0type, 'linearSVM')
                    if ~C0normalized
                        w = originalModel.w;
                        A = [trainData; testData];
                        A = sum(A.^2,2);
                        R2 = max(A);
                    else
                        error('Todo: normalize the weights!');
                    end
                    effectiveStatisticalDimension = norm(w, 2)^2 * R2;  %||w||_2^2 * R^2
                    C0 = effectiveStatisticalDimension / C0delta;
                elseif strcmp(C0type, 'nonLinearSVM')
                    error('TODO: \sum_{i,j} alpha_i y_i alpha_j y_j K(x_i,x_j) and  R^2 will get replaced by max_{x} K(x,x) which, for rbf, will be upper bounded by 1');
                else
                    error('We do not know how to compute the C0 for the given learner');
                end
                Delta = C0*log(k) / (k-1);
            elseif strcmp(obj.deltaType, 'Rademacher-Bootstrap')
                nBoots = getFieldValueOrDefault(obj.C0details, 'nBoots', 10);
                nFeatures = size(trainData,2);
                sampleModel = obj.learner.train(trainWeights, trainData, trainLabel);
                sampleErrorOnSample = binWeightedClassError(obj.learner.predict(sampleModel, trainData), trainWeights, trainLabel);
                bootModels = {};
                bootErrorOnBoot = zeros(nBoots, 1);
                bootErrorOnSample = zeros(nBoots, 1);
                sampleErrorOnBoot = zeros(nBoots, 1);
                for b=1:nBoots
                    fprintf(1,'B-%d ', b);
                    %ind = randsample(obj.randStream, nTrain, nTrain, true);
                    coins = rand(obj.randStream, nTrain,1);
                    ind = find(coins<=0.5);
                    if isempty(ind); ind = randi(obj.randStream, nTrain, 1, 1); end  % to avoid having an empty training data!
                    trainWeightsBS = trainWeights(ind,:);
                    trainDataBS = trainData(ind,:);
                    trainLabelBS = trainLabel(ind,:);
                    bModel = obj.learner.train(trainWeightsBS, trainDataBS, trainLabelBS);
                    bootModels{end+1} = bModel;
                    bootErrorOnBoot(b) = binWeightedClassError(obj.learner.predict(bModel, trainDataBS), trainWeightsBS, trainLabelBS);
                    bootErrorOnSample(b) = binWeightedClassError(obj.learner.predict(bModel, trainData), trainWeights, trainLabel);
                    sampleErrorOnBoot(b) = binWeightedClassError(obj.learner.predict(sampleModel, trainDataBS), trainWeightsBS, trainLabelBS);
                end

                upperBound = (bootErrorOnSample - sampleErrorOnSample) + (sampleErrorOnBoot - bootErrorOnBoot);    
                Delta = quantile(upperBound, 1-C0delta).^2; % since we will take the sqrt of this value
            else
                error('Unsupported delta type');
            end
        end
    end
    
end


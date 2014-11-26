classdef ActiveLearnerProbBeingRight < ActiveLearnerSubsetSampling    
    % Takes the fraction of times that the bootstraped model agree with the
    % current model's predictions as a notion of confidence in our current
    % prediction. Then, it negates the confidence so that lower confidence
    % items have a higher score and get picked more likely.
    properties (Constant)
        scoresEachItemOnlyOnce = false;
        requiredClassifierTypes = {};
    end
    properties
        acronym = 'pbr';
        fullName = 'ProbBeingRight';
    end
    
    properties
        nBoots = true;
    end
    
    methods
        function obj = ActiveLearnerProbBeingRight(classifier, randStream, nBoots)
            obj = obj@ActiveLearnerSubsetSampling(nan, classifier, randStream, true, true, true);                                 
            if exist('nBoots', 'var'); obj.nBoots = nBoots; end
        end
            
        function prob_being_right = calculateScores(obj, trainWeights, trainData, trainLabel, testData)
            bsTime=tic;

            nTest = size(testData,1);
            nTrain = size(trainData,1);
            bootVals = zeros(nTest, obj.nBoots);

            prob_being_right = zeros(nTest, 1);

            currentPredictions = obj.learner.trainPredict(trainWeights, trainData, trainLabel, testData); 

            parfor b=1:obj.nBoots
                fprintf(1,'B-%d ', b);
                ind = randsample(obj.randStream, nTrain, nTrain, true);
                trainWeightsBS = trainWeights(ind,:);
                trainDataBS = trainData(ind,:);
                trainLabelBS = trainLabel(ind,:);
                bootVals(:,b) = obj.learner.trainPredict(trainWeightsBS, trainDataBS, trainLabelBS, testData); 
            end

            parfor i=1:nTest
                numOfPred1 = sum(bootVals(i,:));
                numOfPred0 = obj.nBoots - numOfPred1;
                if currentPredictions(i,1)==1
                    prob_being_right(i,1) = numOfPred1/obj.nBoots; 
                else
                    prob_being_right(i,1) = numOfPred0/obj.nBoots; 
                end
            end

            prob_being_right = -prob_being_right;

            elapsed = toc(bsTime);
            fprintf(1,'ProbBeingRight time=%f\n',elapsed);
        end
    end
    
    methods (Static)
        function msg = desc
            msg = ['This function uses bootstrap to estimate the probability of the current model prediction being right.\n' ...
                'More specifically, takes the fraction of times that the bootstraped model agree with the\n' ...
                'current model''s predictions as a notion of confidence in our current\n' ...
                'prediction. Then, it negates the confidence so that lower confidence\n' ...
                'items have a higher score and get picked more likely.'];
        end
    end

    
end


classdef ActiveLearnerProvost < ActiveLearnerSubsetSampling    
    properties (Constant)
        scoresEachItemOnlyOnce = false;
        requiredClassifierTypes = {'ProbabilisticClassifier'};
    end
    
    properties
        acronym = 'pst';
        fullName = 'Bootstrap-LV';
        nBoots = true;
    end
    
    methods
        function obj = ActiveLearnerProvost(classifier, randStream, nBoots)
            obj = obj@ActiveLearnerSubsetSampling(nan, classifier, randStream, true, true, true);                                 
            if exist('nBoots', 'var'); obj.nBoots = nBoots; end
        end
            
        function bscores = calculateScores(obj, trainWeights, trainData, trainLabel, testData)
            bsTime=tic;

            nTest = size(testData,1);
            nTrain = size(trainData,1);
            bootVals = zeros(nTest, obj.nBoots);
            bscores = zeros(nTest, 1);
            
            minorityClassProb = zeros(1, obj.nBoots);

            minClass = 1 - round(sum(trainLabel) / length(trainLabel)); % finding minority class

            parfor b=1:obj.nBoots
                fprintf(1,'B-%d ', b);
                ind = randsample(obj.randStream, nTrain, nTrain, true);
                trainWeightsBS = trainWeights(ind,:);
                trainDataBS = trainData(ind,:);
                trainLabelBS = trainLabel(ind,:);
                [labels, model, cpe] = obj.learner.trainPredictWithClassProbabilities(trainWeightsBS, trainDataBS, trainLabelBS, testData);
                bootVals(:,b) = cpe(:,1);
                minorityClassProb(b) = mean(cpe(:,1+minClass));
            end

            meanMinClassProb = mean(minorityClassProb);

            parfor i=1:nTest
                bscores(i,1) = var(bootVals(i,:)); % / meanMinClassProb;
            end
           
            elapsed = toc(bsTime);
            fprintf(1,'provost time=%f\n',elapsed);
            
        end
    end
    
    methods (Static)
        function msg = desc
            msg = ['This function is an implementation of the "Active Sampling for Class Probability Estimation and Ranking" by MAYTAL SAAR-TSECHANSKY and FOSTER PROVOST 2004\n']; 
        end
    end

    
end


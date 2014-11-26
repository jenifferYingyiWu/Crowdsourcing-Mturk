classdef ActiveLearnerUncertainty < ActiveLearnerSubsetSampling    
    % Implements the algorithm in Mozafari 2012's paper, by taking the
    % variance of the bootstrap models' predictions
    properties (Constant)
        scoresEachItemOnlyOnce = false;
        requiredClassifierTypes = {};
    end
    
    properties
        acronym = 'var';
        fullName = 'Uncertainty';
        nBoots = true;
    end
    
    methods
        function obj = ActiveLearnerUncertainty(classifier, randStream, nBoots)
            obj = obj@ActiveLearnerSubsetSampling(nan, classifier, randStream, true, true, true);                                 
            if exist('nBoots', 'var'); obj.nBoots = nBoots; end
        end
            
        function varianceScores = calculateScores(obj, trainWeights, trainData, trainLabel, testData)
            bsTime=tic;

            nTest = size(testData,1);
            nTrain = size(trainData,1);
            bootVals = zeros(nTest, obj.nBoots);

            varianceScores = zeros(nTest, 1);

            currentPredictions = obj.learner.trainPredict(trainWeights, trainData, trainLabel, testData); 

            for b=1:obj.nBoots
                fprintf(1,'B-%d ', b);
                ind = randsample(obj.randStream, nTrain, nTrain, true);
                trainWeightsBS = trainWeights(ind,:);
                trainDataBS = trainData(ind,:);
                trainLabelBS = trainLabel(ind,:);
                bootVals(:,b) = obj.learner.trainPredict(trainWeightsBS, trainDataBS, trainLabelBS, testData); 
            end

            % take the variance with the default normalization along each row
            varianceScores(:,:) = var(bootVals, 0, 2);

            elapsed = toc(bsTime);
            fprintf(1,'Uncertainty (Variance) time=%f\n',elapsed);
        end
    end
    
    methods (Static)
        function msg = desc
            msg = ['This function is an implementation of the Uncertainty algorithm by Mozafari et al. 2012, which is simply the variance of the bootstraped model''s predictions\n']; 
        end
        
    end

    
end


classdef ActiveLearnerExpectedModelAccuracy < ActiveLearnerExpectedModelError    
    % This is the Official Implementation of MinExpError funcion in Mozafari et al 2012 paper   
    % scores are 1-  (Pr[current model being right] * error_if_our_model_is_right + Pr[current model being wrong] * error_if_our_model_is_wrong)
       
    properties
        
    end
    
    methods
        function obj = ActiveLearnerExpectedModelAccuracy(classifier, randStream, nBoots)
            obj = obj@ActiveLearnerExpectedModelError(classifier, randStream, nBoots);
            obj.acronym = 'crd';
            obj.fullName = 'ExpectedModelAccuracy';
        end
            
        function expectedTrainingAccuracy = calculateScores(obj, trainWeights, trainData, trainLabel, testData)
            bsTime=tic;

            nTest = size(testData,1);
            nTrain = size(trainData,1);

            expectedModelError = calculateScores@ActiveLearnerExpectedModelError(obj, trainWeights, trainData, trainLabel, testData);

            expectedTrainingAccuracy =  1 - expectedModelError;
            
            elapsed = toc(bsTime);
            fprintf(1,'ActiveLearnerExpectedModelAccuracy time=%f\n',elapsed);
        end
    end
    
    methods (Static)
        function msg = desc
            msg = ['This is the Official Implementation of MinExpError funcion in Mozafari et al 2012 paper.\n' ...
                   'scores are 1-  (Pr[current model being right] * error_if_our_model_is_right + Pr[current model being wrong] * error_if_our_model_is_wrong)'];
        end
    end

    
end


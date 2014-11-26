classdef ActiveLearnerEntropy < ActiveLearnerSubsetSampling    
    % Implements the entropy-based algorithm in "Active Learning Literature
    % Survey" by Burr Settles, page 15. Scores are the entropy between the
    % class probabilities produced by the probabilistic classifier.
    properties (Constant)
        scoresEachItemOnlyOnce = false;
        requiredClassifierTypes = {'ProbabilisticClassifier'};
    end

    properties
        acronym = 'ent';
        fullName = 'Entropy';
        nBoots = true;
    end

    methods
        function obj = ActiveLearnerEntropy(classifier, randStream)
            obj = obj@ActiveLearnerSubsetSampling(nan, classifier, randStream, true, true, true);                                 
        end
            
        function entropyScores = calculateScores(obj, trainWeights, trainData, trainLabel, testData)
            bsTime=tic;

            nTest = size(testData,1);
            entropyScores = zeros(nTest, 1);

            [currentPredictions, model, classProbabilities] = obj.learner.trainPredictWithClassProbabilities(trainWeights, trainData, trainLabel, testData);
            
            % compute the entropy of the class probabilities
            % first get rid of the terms that are zero
            temp = classProbabilities .* log2(classProbabilities);
            temp(classProbabilities==0) = 0; % this is according to Wiki page: http://en.wikipedia.org/wiki/Entropy_%28information_theory%29#Definition
            entropyScores(:,:) = - sum(temp, 2);
            
            elapsed = toc(bsTime);
            fprintf(1,'Entropy time=%f\n',elapsed);
        end
    end
    
    methods (Static)
        function msg = desc
            msg = ['Implements the entropy-based algorithm in "Active Learning Literature Survey" by Burr Settles, page 15.\n' ...
                    'Scores are the entropy between the class probabilities produced by the probabilistic classifier.'];
        end
    end
    
end


classdef ActiveLearnerEntropyBootstrap < ActiveLearnerProbBeingRight    
    % Implements the entropy-based algorithm in "Active Learning Literature
    % Survey" by Burr Settles, page 15. Scores are the entropy between the
    % class probabilities produced by Bootstrap probabilistic classifier.
    properties (Constant)
    end

    properties
    end

    methods
        function obj = ActiveLearnerEntropyBootstrap(classifier, randStream, nBoots)
            obj = obj@ActiveLearnerProbBeingRight(classifier, randStream, nBoots);
            obj.acronym = 'entboot';
            obj.fullName = 'EntropyBootstrap';
        end
            
        function entropyScores = calculateScores(obj, trainWeights, trainData, trainLabel, testData)
            bsTime=tic;

            % we need a negative to account for negative probabilities
            probBeingRight =  - calculateScores@ActiveLearnerProbBeingRight(obj, trainWeights, trainData, trainLabel, testData);
            probBeingWrong = 1-probBeingRight;
            
            nTest = size(testData,1);
            entropyScores = zeros(nTest, 1);

            classProbabilities = [probBeingRight probBeingWrong];
            
            % compute the entropy of the class probabilities
            % first get rid of the terms that are zero
            temp = classProbabilities .* log2(classProbabilities);
            temp(classProbabilities==0) = 0; % this is according to Wiki page: http://en.wikipedia.org/wiki/Entropy_%28information_theory%29#Definition
            entropyScores(:,:) = - sum(temp, 2);
            
            elapsed = toc(bsTime);
            fprintf(1,'EntropyBootstrap time=%f\n',elapsed);
        end
    end
    
    methods (Static)
        function msg = desc
            msg = ['Implements the entropy-based algorithm in "Active Learning Literature Survey" by Burr Settles, page 15.\n' ...
                    'Scores are the entropy between the class probabilities produced by bootstrapped classifiers, i.e. using ProbBeingRight to estimate class probabilities.'];
        end
    end
    
end


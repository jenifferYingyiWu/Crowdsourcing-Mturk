classdef bClassifier < ProbabilisticClassifier
    properties (Constant)
    end
    
    properties
    end
    
    methods       
        function internalModel = i_train(obj, TrainingData, TrainLabel, Options)
            internalModel = NaiveBayes.fit(TrainingData, TrainLabel, 'Distribution', 'kernel', 'Prior', 'empirical');
        end
        
        function [TestLabel, classProbabilities] = i_predict_with_class_probabilities(obj, internalModel, TestData, Options)
            [classProbabilities, TestLabel] = internalModel.posterior(TestData);
            nanidx = find(isnan(TestLabel));
            if ~isempty(nanidx)
            %    warning('you had null labels from bClassify');
                randSeed = length(nanidx);
                randStream = RandStream('mt19937ar','seed', randSeed);
                TestLabel(nanidx) = randsample(randStream, [0 1], length(nanidx), true)';
                classProbabilities(isnan(classProbabilities)) = 0.5;
            end
        end
    end
    
end


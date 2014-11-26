classdef twClassifier < WeightedClassifier & ProbabilisticClassifier
    properties (Constant)
    end
    
    properties
    end
    
    methods       
        function internalModel = i_weighted_train(obj, TrainWeights, TrainingData, TrainLabel, Options)
            internalModel = classregtree(TrainingData, TrainLabel, 'weights', TrainWeights, 'method', 'classification', 'prune', 'off', 'minparent', 1, 'mergeleaves', 'off');
        end
        
        function [TestLabel, classProbabilities] = i_predict_with_class_probabilities(obj, internalModel, TestData, Options)
            [labels, nodes] = internalModel.eval(TestData);
            TestLabel = strcmp(labels, '1');
            classProbabilities = internalModel.classprob(nodes);
        end
    end
    
end


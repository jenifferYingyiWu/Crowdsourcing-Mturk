classdef tClassifier < ProbabilisticClassifier
    properties (Constant)
    end
    
    methods        
        function internalModel = i_train(obj, TrainingData, TrainLabel, Options)
            internalModel = classregtree(TrainingData, TrainLabel, 'method', 'classification', 'prune', 'off', 'minparent', 1, 'mergeleaves', 'off');
        end
        
        function [TestLabel, classProbabilities] = i_predict_with_class_probabilities(obj, internalModel, TestData, Options)
            [labels, nodes] = internalModel.eval(TestData);
            TestLabel = strcmp(labels, '1');
            classProbabilities = internalModel.classprob(nodes);
        end
    end
    
end


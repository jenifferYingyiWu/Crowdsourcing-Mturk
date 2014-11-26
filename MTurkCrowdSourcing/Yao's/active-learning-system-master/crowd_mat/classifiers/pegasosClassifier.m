classdef pegasosClassifier < Classifier
    properties (Constant)
    end
    
    properties
    end
    
    methods
        function internalModel = i_train(obj, TrainingData, TrainLabel, Options)
            [wT, b] = pegasos(TrainingData, 2*TrainLabel-1);
            internalModel = struct('w', wT', 'b', b);
        end
        
        function TestLabels = i_predict(obj, internalModel, TestData, Options)
            TestLabels = sign(TestData*internalModel.w+internalModel.b); % this is -1 and +1 labels
            TestLabels = (TestLabels+1) / 2; % to make the labels 0 and 1
        end
    end
    
end


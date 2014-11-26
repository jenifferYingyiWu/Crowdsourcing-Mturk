classdef sClassifierFast < Classifier
    properties (Constant)
    end
    
    properties
    end
    
    methods       
        function internalModel = i_train(obj, TrainingData, TrainLabel, Options)
            internalModel = libsvm.matlab.svmtrain(TrainLabel, TrainingData, '-s 0 -t 0 -q'); % get rid of -q to get error messages
        end
        
        function TestLabels = i_predict(obj, internalModel, TestData, Options)
            garbage = zeros(size(TestData,1),1);
            TestLabels = libsvm.matlab.svmpredict(garbage, TestData, internalModel, '-q');
        end
    end
    
end


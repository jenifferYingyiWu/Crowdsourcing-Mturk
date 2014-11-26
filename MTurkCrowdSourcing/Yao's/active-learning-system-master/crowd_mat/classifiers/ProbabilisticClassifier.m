classdef (Abstract) ProbabilisticClassifier < Classifier
    properties (Abstract, Constant)
    end
    
    methods(Abstract) 
        [TestLabel, classProbabilities] = i_predict_with_class_probabilities(obj, internalModel, TestData, Options);
    end
    
    methods % Public
        function TestLabel = i_predict(obj, internalModel, TestData, Options)
            [TestLabel, classProbabilities] = i_predict_with_class_probabilities(obj, internalModel, TestData, Options);
        end
        
        function [TestLabel, classProbabilities] = predictWithClassProbabilities(obj, prevModel, TestData, Options)
            if ~exist('Options','var'); Options=[]; end
            if isempty(TestData)
                TestLabel = zeros(0,1);
                classProbabilities = zeros(0,2);
            elseif isfield(prevModel, 'fixedClassifierValue')
                fixedVal = prevModel.fixedClassifierValue;
                TestLabel = ones(size(TestData,1),1) * fixedVal; 
                classProbabilities = zeros(size(TestData,1),2); 
                classProbabilities(1+fixedVal) = 1;
            else
                [TestLabel, classProbabilities] = obj.i_predict_with_class_probabilities(prevModel.internalModel, TestData, Options);
            end
        end
       
        function [TestLabel, model, classProbabilities] = trainPredictWithClassProbabilities(obj, TrainWeights, TrainingData, TrainLabel, TestData, Options)
            if ~exist('Options','var'); Options=[]; end
            model = train(obj, TrainWeights, TrainingData, TrainLabel, Options);
            [TestLabel, classProbabilities] = predictWithClassProbabilities(obj, model, TestData, Options);
        end
        
        function [TestLabel, model, classProbabilities] = trainIncPredictWithClassProbabilities(obj, TrainWeights, TrainingData, TrainLabel, TestData, prevModel, Options)
            if ~exist('Options','var'); Options=[]; end
            model = trainInc(obj, TrainWeights, TrainingData, TrainLabel, prevModel, Options);
            [TestLabel, classProbabilities] = predictWithClassProbabilities(obj, model, TestData, Options);
        end
        
    end
    
end
    


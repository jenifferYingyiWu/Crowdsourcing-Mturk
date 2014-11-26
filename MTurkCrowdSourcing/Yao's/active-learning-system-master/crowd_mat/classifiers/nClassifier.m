classdef nClassifier < Classifier
    properties (Constant)
    end
    
    properties
        hiddenLayerSize = 10;
    end
    
    methods
        function obj = sClassifier(hiddenLayerSize) 
            if exist('hiddenLayerSize', 'var'); obj.hiddenLayerSize = hiddenLayerSize; end
        end
        
        function internalModel = i_train(obj, TrainingData, TrainLabel, Options)
            % Create a Pattern Recognition Network
            model = patternnet(obj.hiddenLayerSize);

            % Setup Division of Data for Training, Validation, Testing
            model.divideParam.trainRatio = 1; %70/100;
            model.divideParam.valRatio = 0; %15/100;
            model.divideParam.testRatio = 0; %15/100;

            model.trainParam.showWindow = false;
            %net.trainParam.showGUI = false;

            [internalModel, tr] = train(model, TrainingData', TrainLabel');
        end
        
        function TestLabels = i_predict(obj, internalModel, TestData, Options)
            TestLabels = internalModel(TestData')'; 
        end
    end
    
end


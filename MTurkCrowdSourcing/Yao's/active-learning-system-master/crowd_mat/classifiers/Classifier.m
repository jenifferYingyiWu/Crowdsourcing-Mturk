classdef (Abstract) Classifier < handle
    properties (Abstract, Constant)
    end
    
    methods(Abstract) % I wish I could make these two hidden!
        internalModel = i_train(obj, TrainData, TrainLabel, Options);
        TestLabels = i_predict(obj, internalModel, TestData, Options);
    end
    
    methods % Public
        
        %Needs to be overridden
        function model = train(obj, TrainWeights, TrainData, TrainLabel, Options)
            if ~exist('Options','var'); Options=[]; end
            [TrainWeights, TrainData, TrainLabel] = simulateWeights(TrainWeights, TrainData, TrainLabel); 
            vMin = min(TrainLabel); vMax = max(TrainLabel);
            if vMin == vMax
                model = struct('fixedClassifierValue', vMax, 'prevData', struct('TrainWeights', TrainWeights, 'TrainData', TrainData, 'TrainLabel', TrainLabel));
            else 
                internalModel = obj.i_train(TrainData, TrainLabel, Options);
                model.internalModel = internalModel;
            end
            model.prevData = struct('TrainWeights', TrainWeights, 'TrainData', TrainData, 'TrainLabel', TrainLabel);            
        end

        %Needs to be overridden        
        function model = trainInc(obj, TrainWeights, TrainData, TrainLabel, prevModel, Options)
            if ~exist('Options','var'); Options=[]; end
            warning('This classifier does not support incremental training');

            TrainWeights = [prevModel.prevData.TrainWeights; TrainWeights];
            TrainData = [prevModel.prevData.TrainData; TrainData];
            TrainLabel = [prevModel.prevData.TrainLabel; TrainLabel];
            model = train(obj, TrainWeights, TrainData, TrainLabel, Options);          
        end
        
        
        function TestLabels = predict(obj, prevModel, TestData, Options)
            if ~exist('Options','var'); Options=[]; end
            if isempty(TestData)
                TestLabels = zeros(0,1);
            elseif isfield(prevModel, 'fixedClassifierValue')
                fixedVal = prevModel.fixedClassifierValue;
                TestLabels = ones(size(TestData,1),1) * fixedVal;
            else
                TestLabels = obj.i_predict(prevModel.internalModel, TestData, Options);
            end
            
        end
        
        function [TestLabels, model] = trainPredict(obj, TrainWeights, TrainData, TrainLabel, TestData, Options)
            if ~exist('Options','var'); Options=[]; end
            model = train(obj, TrainWeights, TrainData, TrainLabel, Options);
            TestLabels = predict(obj, model, TestData, Options);
        end
        
        function [TestLabels, model] = trainIncPredict(obj, TrainWeights, TrainData, TrainLabel, TestData, prevModel, Options)
            if ~exist('Options','var'); Options=[]; end
            model = trainInc(obj, TrainWeights, TrainData, TrainLabel, prevModel, Options);
            TestLabels = predict(obj, model, TestData, Options);
        end
    end
    
    
end
    


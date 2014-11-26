classdef (Abstract) IncrementalClassifier < Classifier
    properties (Abstract, Constant)
    end
    methods(Abstract) % I wish I could make these two hidden!
        internalModel = i_incremental_train(obj, TrainingData, TrainLabel, prevModel, Options);
    end
    
    methods % Public        
        %Needs to be overridden
        function model = train(obj, TrainWeights, TrainingData, TrainLabel, Options)
            if ~exist('Options','var'); Options=[]; end
            [TrainWeights, TrainingData, TrainLabel] = simulateWeights(TrainWeights, TrainingData, TrainLabel); 
            vMin = min(TrainLabel); vMax = max(TrainLabel);
            if vMin == vMax
                model = struct('fixedClassifierValue', vMax, 'prevData', struct('TrainWeights', TrainWeights, 'TrainingData', TrainingData, 'TrainLabel', TrainLabel));
                model.prevData = struct('TrainWeights', TrainWeights, 'TrainingData', TrainingData, 'TrainLabel', TrainLabel);            
            else 
                internalModel = obj.i_train(TrainingData, TrainLabel, Options);
                model.internalModel = internalModel;
            end
        end

        %Needs to be overridden        
        function model = trainInc(obj, TrainWeights, TrainingData, TrainLabel, prevModel, Options)
            if ~exist('Options','var'); Options=[]; end
            vMin = min(TrainLabel); vMax = max(TrainLabel);
            assert(isfield(prevModel, 'prevData') || isfield(prevModel, 'internalModel'));
            if vMin == vMax && isfield(prevModel, 'prevData')
                model = train(obj, [prevModel.prevData.TrainWeights; TrainWeights], ...
                                   [prevModel.prevData.TrainWeights; TrainingData], ...
                                   [prevModel.prevData.TrainLabel; TrainLabel], Options);
            else
                [TrainWeights, TrainingData, TrainLabel] = simulateWeights(TrainWeights, TrainingData, TrainLabel);
                internalModel = obj.i_incremental_train(TrainingData, TrainLabel, prevModel.internalModel, Options);
                model.internalModel = internalModel;
            end
        end
    
    end
    
end
    


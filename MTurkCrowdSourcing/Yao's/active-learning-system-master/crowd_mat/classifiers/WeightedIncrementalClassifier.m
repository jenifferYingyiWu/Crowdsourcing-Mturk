classdef (Abstract) WeightedIncrementalClassifier < WeightedClassifier & IncrementalClassifier
    properties (Constant)
    end
    
    methods (Abstract)
        internalModel = i_weighted_incremental_train(obj, TrainWeights, TrainingData, TrainLabel, prevModel, Options);        
    end
    
    methods
        %Needs to be overridden
        function model = train(obj, TrainWeights, TrainingData, TrainLabel, Options)
            if ~exist('Options','var'); Options=[]; end
            vMin = min(TrainLabel); vMax = max(TrainLabel);
            if vMin == vMax
                model = struct('fixedClassifierValue', vMax, 'prevData', struct('TrainWeights', TrainWeights, 'TrainingData', TrainingData, 'TrainLabel', TrainLabel));
                model.prevData = struct('TrainWeights', TrainWeights, 'TrainingData', TrainingData, 'TrainLabel', TrainLabel);            
            else 
                internalModel = obj.i_weighted_train(TrainWeights, TrainingData, TrainLabel, Options);
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
                internalModel = obj.i_weighted_incremental_train(TrainWeights, TrainingData, TrainLabel, prevModel.internalModel, Options);
                model.internalModel = internalModel;
            end
        end
                
        function internalModel = i_incremental_train(obj, TrainingData, TrainLabel, prevModel, Options)
            if ~exist('Options','var'); Options=[]; end
            internalModel = i_weighted_incremental_train(obj, ones(size(TrainLabel)), TrainingData, TrainLabel, prevModel, Options);
        end
        
    end
    
end


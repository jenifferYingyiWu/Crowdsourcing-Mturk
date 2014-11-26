classdef (Abstract) WeightedClassifier < Classifier
    properties (Abstract, Constant)
    end
    methods(Abstract) % I wish I could make these two hidden!
        internalModel = i_weighted_train(obj, TrainWeights, TrainingData, TrainLabel, Options);
    end
    
    methods % Public
        %Needs to be overridden
        function model = train(obj, TrainWeights, TrainingData, TrainLabel, Options)
            if ~exist('Options','var'); Options=[]; end
            vMin = min(TrainLabel); vMax = max(TrainLabel);
            if vMin == vMax
                model = struct('fixedClassifierValue', vMax, 'prevData', struct('TrainWeights', TrainWeights, 'TrainingData', TrainingData, 'TrainLabel', TrainLabel));
            else 
                internalModel = obj.i_weighted_train(TrainWeights, TrainingData, TrainLabel, Options);
                model.internalModel = internalModel;
            end
            model.prevData = struct('TrainWeights', TrainWeights, 'TrainingData', TrainingData, 'TrainLabel', TrainLabel);            
        end

        %Needs to be overridden        
        function model = trainInc(obj, TrainWeights, TrainingData, TrainLabel, prevModel, Options)
            if ~exist('Options','var'); Options=[]; end
            warning('This classifier does not support incremental training');

            TrainWeights = [prevModel.prevData.TrainWeights; TrainWeights];
            TrainingData = [prevModel.prevData.TrainingData; TrainingData];
            TrainLabel = [prevModel.prevData.TrainLabel; TrainLabel];
            model = train(obj, TrainWeights, TrainingData, TrainLabel, Options);
        end
        
        function internalModel = i_train(obj, TrainingData, TrainLabel, Options)
            internalModel = i_weighted_train(obj, ones(size(TrainLabel)), TrainingData, TrainLabel, Options);
        end
            
    end
end
    


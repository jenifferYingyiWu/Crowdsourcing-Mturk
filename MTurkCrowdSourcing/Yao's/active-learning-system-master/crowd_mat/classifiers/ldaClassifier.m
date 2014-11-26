classdef ldaClassifier < WeightedIncrementalClassifier
    properties (Constant)
    end
    
    properties
        lambda = 1.5;
    end
    
    methods
        function obj = ldaClassifier(lambda) 
            if exist('lambda', 'var'); obj.lambda = lambda; end
        end
        
        function internalModel = i_weighted_train(obj, TrainWeights, TrainingData, TrainLabel, Options)
            error('not supported yet');
        end
        
        function internalModel = i_weighted_incremental_train(obj, TrainWeights, TrainingData, TrainLabel, prevModel, Options);
            error('not supported yet');
        end

        % remove this once you figure out the weights!
        function internalModel = i_train(obj, TrainingData, TrainLabel, Options)
            nFeatures = size(TrainingData,2);
            internalModel.rls = (TrainingData' * TrainingData + obj.lambda * eye(nFeatures))^-1 * TrainingData * TrainLabel;
            internalModel.q = TrainLabel' * TrainingData;
            internalModel.p_inverse = [];
        end

        % remove this once you figure out the weights!
        function internalModel = i_incremental_train(obj, TrainingData, TrainLabel, prevModel, Options); 
            internalModel = prevModel;
            if isempty(internalModel.p_inverse)
                internalModel.p_inverse = internalModel.rls / internalModel.q;
            end
            % now update q
            internalModel.q = internalModel.q + TrainLabel' * TrainingData;
            % now update p_inverse
            for i=1:size(TrainLabel, 1)
                x = TrainingData(i,:);
                y = TrainLabel(i);
                internalModel.p_inverse = internalModel.p_inverse - (1+x' * internalModel.p_inverse  * x)^-1 * (internalModel.p_inverse * x) * (internalModel.p_inverse * x)';
            end
            % now update rls
            internalModel.rls = internalModel.p_inverse * internalModel.q;
        end
        
        
        function TestLabels = i_predict(obj, internalModel, TestData, Options)
            Y = TestData * internalModel;
            TestLabels = ones(size(Y));
            TestLabels(Y<0.5) = 0;
        end
    end
    
end


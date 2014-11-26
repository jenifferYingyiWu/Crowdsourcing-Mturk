classdef rlsClassifier < WeightedIncrementalClassifier
    properties (Constant)
    end
    
    properties
        lambda = 1.5;
    end
    
    methods
        function obj = rlsClassifier(lambda) 
            if exist('lambda', 'var'); obj.lambda = lambda; end
        end
        
        function internalModel = i_weighted_train(obj, TrainWeights, TrainingData, TrainLabel, Options)
            %TODO: A^-1 * B with A \ B
            nFeatures = size(TrainingData,2);
            W = diag(TrainWeights);
            internalModel.rls = (TrainingData' * W * TrainingData + obj.lambda * eye(nFeatures)) \ TrainingData' * W * TrainLabel;
            
            % compute q and p
            internalModel.q = (TrainWeights .* TrainLabel)' * TrainingData;
            internalModel.p_inverse = (1/obj.lambda) * eye(nFeatures);
            for i=1:size(TrainLabel, 1)
                x = TrainingData(i,:);
                y = TrainLabel(i);
                w = TrainWeights(i);
                internalModel.p_inverse = ...
                    internalModel.p_inverse - w*(1+w * x * internalModel.p_inverse  * x') \ (internalModel.p_inverse * x') * (internalModel.p_inverse * x')';
            end
            
            % to be commented out: this is just to check that our recusive
            % formula is correct!
%            assert (all(abs(internalModel.rls - internalModel.p_inverse * internalModel.q') < 0.01 * abs(internalModel.rls)));
        end
        
        % (P + w a a')^{-1} = Pi + [  w  /  (1 + w a' Pi a) ] (Pi a) (Pi a)'
        % here, Pi is P^-1
        function internalModel = i_weighted_incremental_train(obj, TrainWeights, TrainingData, TrainLabel, prevModel, Options);
            internalModel = prevModel;
            %if isempty(internalModel.p_inverse)
            %    internalModel.p_inverse = internalModel.rls * internalModel.q^-1;
            %end
            
            % now update q
            internalModel.q = internalModel.q + (TrainWeights .* TrainLabel)' * TrainingData;
            % now update p_inverse
            for i=1:size(TrainLabel, 1)
                x = TrainingData(i,:);
                y = TrainLabel(i);
                w = TrainWeights(i);
                internalModel.p_inverse = ...
                    internalModel.p_inverse - w*(1+w * x * internalModel.p_inverse  * x') \ (internalModel.p_inverse * x') * (internalModel.p_inverse * x')';
            end
            % now update rls
            internalModel.rls = internalModel.p_inverse * internalModel.q';
        end        
        
        function TestLabels = i_predict(obj, internalModel, TestData, Options)
            Y = TestData * internalModel.rls;
            TestLabels = ones(size(Y));
            TestLabels(Y<0.5) = 0;
        end
    end
    
end


classdef incSClassifier < IncrementalClassifier
    properties (Constant)
    end
    
    properties
        solverType = 2;
        costC = 20;
        bias = 10;
        terminationTolerance = 0.0000001;
        lossTolerance = 0.1;
    end
    
    methods
        function obj = incSClassifier(solverType, costC, bias, terminationTolerance, lossTolerance) 
            if exist('solverType', 'var'); obj.solverType = solverType; end
            if exist('costC', 'var'); obj.costC = costC; end
            if exist('bias', 'var'); obj.bias = bias; end
            if exist('terminationTolerance', 'var'); obj.terminationTolerance = terminationTolerance; end
            if exist('lossTolerance', 'var'); obj.lossTolerance = lossTolerance; end
        end
        
        function internalModel = i_train(obj, TrainingData, TrainLabel, Options)
            N = size(TrainLabel, 1);
            N0 = length(find(TrainLabel==0));
            N1 = length(find(TrainLabel==1));
            s0 = N / (2*N0);
            s1 = N / (2*N1);

            Dtrain = sparse(TrainingData);
            params = ['-s ' num2str(obj.solverType) ' -c ' num2str(obj.costC) ' -p ' num2str(obj.lossTolerance)];
            params = [params ' -e ' num2str(obj.terminationTolerance) ' -B ' num2str(obj.bias) ' -q -w0 ' num2str(s0) ' -w1 ' num2str(s1)];
            internalModel = lltrain(TrainLabel, Dtrain, params);
        end

        function internalModel = i_incremental_train(obj, TrainingData, TrainLabel, prevModel, Options);
            N = size(TrainLabel, 1);
            N0 = length(find(TrainLabel==0));
            N1 = length(find(TrainLabel==1));
            s0 = N / (2*N0);
            s1 = N / (2*N1);

            Dtrain = sparse(TrainingData);
            params = ['-s ' num2str(obj.solverType) ' -c ' num2str(obj.costC) ' -p ' num2str(obj.lossTolerance)];
            params = [params ' -e ' num2str(obj.terminationTolerance) ' -B ' num2str(obj.bias) ' -q -w0 ' num2str(s0) ' -w1 ' num2str(s1)];            
            internalModel = inc_lltrain(prevModel, TrainLabel, Dtrain, params);
        end
        
        function TestLabels = i_predict(obj, internalModel, TestData, Options)
            Dtest = sparse(TestData);
            TestLabels = llpredict(zeros(size(TestData,1),1), Dtest, internalModel);
        end
        

    end
    
end


classdef sClassifier < Classifier
    properties (Constant)
    end
    
    properties
        maxIterations = 2000;
        optimizationMethod = 'SMO';
        kernelFunction = 'linear';
    end
    
    methods
        function obj = sClassifier(maxIterations, optimizationMethod, kernelFunction) 
            if exist('maxIterations', 'var'); obj.maxIterations = maxIterations; end
            if exist('optimizationMethod', 'var'); obj.optimizationMethod = optimizationMethod; end
            if exist('kernelFunction', 'var'); obj.kernelFunction = kernelFunction; end
        end
        
        function internalModel = i_train(obj, TrainingData, TrainLabel, Options)
            options = optimset('maxiter', obj.maxIterations);

            internalModel = svmtrain(TrainingData, TrainLabel, 'Kernel_Function', obj.kernelFunction, 'Method', obj.optimizationMethod, 'BoxConstraint', 1, 'AutoScale', true, 'options', options); %, 'kktviolationlevel', 0.05, 'tolkkt', 1e-2); %, 'Method', 'QP', 'quadprog_opts',options);        
        end
        
        function TestLabels = i_predict(obj, internalModel, TestData, Options)
            TestLabels = svmclassify(internalModel, TestData);
        end
    end
    
end


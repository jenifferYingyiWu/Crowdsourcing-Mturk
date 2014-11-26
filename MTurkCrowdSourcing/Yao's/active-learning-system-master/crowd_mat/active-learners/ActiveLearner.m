classdef (Abstract) ActiveLearner < handle    
    properties
        crowdManager;
        learner;
        randStream;
    end
    
    properties (Abstract, Constant)
        canConsumeExactBudget;
        scoresEachItemOnlyOnce;
        requiredClassifierTypes;
    end
    
    properties (Abstract)
        fullName;
        acronym;
    end
    
    methods (Abstract)
        scores = calculateScores(TrainWeights, TrainData, TrainLabels, UnlabeledData);
        [newChosenIdx, newChosenWeights] = chooser(unlabeledIdx, scores, howManyToChoose);
    end
    
    methods (Abstract, Static)
        msg = desc;
    end
    
    methods
        function obj = ActiveLearner(crowdManager, learner, randStream)
            obj.crowdManager = crowdManager;
            obj.learner = learner;
            obj.randStream = randStream;
            if ~obj.isClassifierSupported(learner)
                error(['Your classifier ' class(learner) ' must support all of the following features ' valueToString(obj.requiredClassifierTypes)]);
            end
        end
        
        function [newChosenIdx, newChosenWeights] = chooseItems(obj, unlabeledIdx, TrainWeights, TrainData, TrainLabels, UnlabeledData, howManyToChoose)
            scores = obj.calculateScores(TrainWeights, TrainData, TrainLabels, UnlabeledData);
            [newChosenIdx, newChosenWeights] = obj.chooser(unlabeledIdx, scores, howManyToChoose);
        end
                
    end
    
    methods (Access = private)
        function classifierIsSupported = isClassifierSupported(obj, learner)
            classifierIsSupported = true;
            for i=1:length(obj.requiredClassifierTypes)
                classifierType = obj.requiredClassifierTypes{i};
                if ~isa(learner, classifierType)
                    classifierIsSupported = false;
                    break;
                end
            end
        end
    end
end


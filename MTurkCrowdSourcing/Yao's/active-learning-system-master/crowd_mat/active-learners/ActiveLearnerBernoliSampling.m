classdef (Abstract) ActiveLearnerBernoliSampling < ActiveLearner    
    properties (Constant)
    end
    
    properties
        useWeightedSampling = true;
        updateWeights = true;
        randomizeSelection = true;
    end
    
    methods
        function obj = ActiveLearnerBernoliSampling(crowdManager, learner, randStream)
            obj = obj@ActiveLearner(crowdManager, learner, randStream);
        end
        
        function [chosenIdx, chosenWeights] = chooser(obj, unlabeledIdx, scores, howManyToChoose)
            coins = rand(obj.randStream, size(scores));
            coins = find(coins<=scores);
            chosenIdx = unlabeledIdx(coins);
            chosenWeights = 1./scores(coins);
        end
    end
    
end


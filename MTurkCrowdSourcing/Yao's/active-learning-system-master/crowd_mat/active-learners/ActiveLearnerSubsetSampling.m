classdef (Abstract) ActiveLearnerSubsetSampling < ActiveLearner    
    properties (Constant)
        canConsumeExactBudget = true;
    end
    
    properties
        useWeightedSampling = true;
        updateWeights = true;
        randomizeSelection = true;
    end
    
    methods
        function obj = ActiveLearnerSubsetSampling(crowdManager, classifier, randStream, useWeightedSampling, updateWeights, randomizeSelection)
            obj = obj@ActiveLearner(crowdManager, classifier, randStream);
            if exist('useWeightedSampling', 'var'); obj.useWeightedSampling = useWeightedSampling; end
            if exist('updateWeights', 'var'); obj.updateWeights = updateWeights; end
            if exist('randomizeSelection', 'var'); obj.randomizeSelection = randomizeSelection; end
        end
        
        function [chosenIdx, chosenWeights] = chooser(obj, unlabeledIdx, scores, howManyToChoose)
            %TODO: not clear what the choiceProbability actually means when howManyToChoose > 1
            assert (length(unlabeledIdx)==length(scores));

            chosenIdx = zeros(howManyToChoose, 1);
            chosenWeights = zeros(howManyToChoose, 1);

            if ~obj.useWeightedSampling % just choose the "top" newWeCanAsk question, those with maximum scores!
                for minIdx=1:howManyToChoose
                    [v, idx] = max(scores);
                    if obj.randomizeSelection
                        all_idx = find(scores==v);
                        idx = randsample(obj.randStream, all_idx, 1);
                    end
                    adjustedProb = 1; % I don't know how to re-weigh the new item when we take the max!

                    actualIdx = unlabeledIdx(idx);
                    unlabeledIdx(idx) = [];
                    scores(idx) = [];

                    chosenIdx(minIdx) = actualIdx;
                    chosenWeights(minIdx) = adjustedProb;
                end
            else % use weighted sampling according to the scores numbers! the higher the rank, the more likely that question will be asked!
                for minIdx=1:howManyToChoose
                    nr = normMatrix(scores);
                    if max(nr)==0
                        nr(:) = 1;
                    end
                    idx = randsample(obj.randStream, length(scores), 1, true, nr);
                    adjustedProb = nr(idx); % to follow IWAL's paradigm!
                    actualIdx = unlabeledIdx(idx);
                    unlabeledIdx(idx) = [];
                    scores(idx) = [];

                    chosenIdx(minIdx) = actualIdx;
                    chosenWeights(minIdx) = adjustedProb;
                end
            end
            
            if ~obj.updateWeights
                chosenWeights(:) = 1;
            end
            
        end
    end
    
end


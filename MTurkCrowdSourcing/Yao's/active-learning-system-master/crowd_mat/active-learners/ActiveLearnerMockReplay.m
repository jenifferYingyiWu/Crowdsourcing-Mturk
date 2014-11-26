classdef ActiveLearnerMockReplay < ActiveLearnerSubsetSampling    
    properties (Constant)
    end
    
    properties
        decisionFilename;
        fixedOrderIdx;
    end
    
    methods
        function obj = ActiveLearnerMockReplay(crowdManager, classifier, randStream, decisionFilename)
            obj = obj@ActiveLearnerSubsetSampling(crowdManager, classifier, randStream);
            obj.decisionFilename = decisionFilename;
            fixedOrderPrimaryKeys = load(obj.decisionFilename, '-ascii');
            %fixedOrderPrimaryKeys = [6 4 2 3 2 1 1:8000];
            obj.fixedOrderIdx = crowdManager.mapPrimaryKeyToIndex(fixedOrderPrimaryKeys);
        end
        
        function [chosenIdx, chosenWeights] = chooser(obj, unlabeledIdx, scores, howManyToChoose)
            chosenIdx = zeros(howManyToChoose, 1);
            chosenWeights = zeros(howManyToChoose, 1);
            
            nextGuyIdx=1;
            lastGuyPicked=0;
            while nextGuyIdx <= howManyToChoose
                lastGuyPicked=lastGuyPicked+1;
                where = find(unlabeledIdx==obj.fixedOrderIdx(lastGuyPicked));
                if ~isempty(where)
                    chosenIdx(nextGuyIdx) = unlabeledIdx(where);
                    chosenWeights(nextGuyIdx) = 1;
                    unlabeledIdx(where) = [];
                    nextGuyIdx = nextGuyIdx+1;
                end            
            end            
        end
        
        function scores = obj.calculateScores(TrainWeights, TrainData, TrainLabels, UnlabeledData)
            % this is a dummy thing!
            scores = zeros(size(UnlabeledData,1), 1);
        end        
    end
    
end


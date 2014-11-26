function [chosenIdx, chosenWeights] = chooser(unlabeledIdx, scores, howManyToChoose, chooserOptions)
%TODO: not clear what the choiceProbability actually means when howManyToChoose > 1
assert (length(unlabeledIdx)==length(scores));

chosenIdx = zeros(howManyToChoose, 1);
chosenWeights = zeros(howManyToChoose, 1);

if strcmp(chooserOptions.strategy, 'bernoliWeightedSampling')
    coins = rand(chooserOptions.randStream, size(scores));
    coins = find(coins<=scores);
    chosenIdx = unlabeledIdx(coins);
    chosenWeights = 1./scores(coins);
elseif strcmp(chooserOptions.strategy, 'maxScores') % just choose the "top" newWeCanAsk question
    for minIdx=1:howManyToChoose
        [v, idx] = max(scores);
        if chooserOptions.randomizeSelection
            all_idx = find(scores==v);
            idx = randsample(chooserOptions.randStream, all_idx, 1);
        end
        adjustedProb = 1; % I don't know how to re-weigh the new item when we take the max!
        
        actualIdx = unlabeledIdx(idx);
        unlabeledIdx(idx) = [];
        scores(idx) = [];

        chosenIdx(minIdx) = actualIdx;
        chosenWeights(minIdx) = adjustedProb;
    end
elseif strcmp(chooserOptions.strategy, 'rescalingWeightedSampling') % use weighted sampling according to the scores numbers! the higher the rank, the more likely that question will be asked!
    for minIdx=1:howManyToChoose
        nr = normMatrix(scores);
        if max(nr)==0
            nr(:) = 1;
        end
        idx = randsample(chooserOptions.randStream, length(scores), 1, true, nr);
        adjustedProb = nr(idx); % to follow IWAL's paradigm!
        actualIdx = unlabeledIdx(idx);
        unlabeledIdx(idx) = [];
        scores(idx) = [];

        chosenIdx(minIdx) = actualIdx;
        chosenWeights(minIdx) = adjustedProb;
    end
elseif strcmp(chooserOptions.strategy, 'AlreadyDecided')    
    if ~isfield(chooserOptions, 'CrowdManager')
        error('AlreadyDecided Needs CrowdManager');
    else
        cm = chooserOptions.CrowdManager;
    end

    if ~isfield(chooserOptions, 'ReplayFile')
        error('AlreadyDecided Needs ReplayFile');
    else
        fixedOrderPrimaryKeys = load(chooserOptions.ReplayFile, '-ascii');
        %fixedOrderPrimaryKeys = [6 4 2 3 2 1 1:8000];
        fixedOrderIdx = cm.mapPrimaryKeyToIndex(fixedOrderPrimaryKeys);
    end
    
    nextGuyIdx=1;
    lastGuyPicked=0;
    while nextGuyIdx <= howManyToChoose
        lastGuyPicked=lastGuyPicked+1;
        where = find(unlabeledIdx==fixedOrderIdx(lastGuyPicked));
        if ~isempty(where)
            chosenIdx(nextGuyIdx) = unlabeledIdx(where);
            chosenWeights(nextGuyIdx) = 1;
            unlabeledIdx(where) = [];
            nextGuyIdx = nextGuyIdx+1;
        end            
    end
else
    error('Unsupported Choosing Strategy: ' );
end

end


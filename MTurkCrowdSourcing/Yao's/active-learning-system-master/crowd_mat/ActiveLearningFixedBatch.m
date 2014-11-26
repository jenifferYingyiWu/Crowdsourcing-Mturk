function [avgImprovement, relAvgImprovement, msg] = ActiveLearningFixedBatch(datasetConfig, activeLearner, budgetStruct, randSeed, repetitionFactor, resultFileName)
%   Detailed explanation goes here

[algRand, cmRand, baseLineRand] = computeRandSeeds(randSeed, false);
%cmRand = algRand;
%baseLineRand = algRand;
%RandStream.setGlobalStream(algRand);
activeLearner.randStream = algRand;
provenance = struct('functionName', 'ActiveLearningFixedBatch' , 'datetime', datestr(now,'local'), 'randSeed', randSeed);
algorithmInfo = struct('activeLearner', activeLearner, 'budgetStruct', budgetStruct);
eMgr = ExperimentManager(datasetConfig, algorithmInfo, provenance, repetitionFactor, resultFileName, algRand, baseLineRand);

for experimentId=1:eMgr.repetitionFactor
cm = CrowdManager(datasetConfig.datafile, datasetConfig.primaryKeyCol, datasetConfig.classCol, datasetConfig.crowdUserCols, datasetConfig.crowdLabelCols, datasetConfig.featureCols, datasetConfig.fakeCrowd, datasetConfig.balancedLabels, cmRand, true, datasetConfig.inputFilePath);
% reset the experiment for this iteration
eMgr.resetForNewIteration(cm);

%split into train and test
[trainRange, testRange] = splitRange(cm.numberOfItems, datasetConfig.initialTrainRatio);
testRange = shuffle(testRange, baseLineRand);
nTest = length(testRange);
%what would happen if we were allowed to ask a fixed number of questions, i.e. our budget.
[whatYouCanSee, budgetPerStep, budgetReportingFrequency, totalBudget] = computeBudgets(budgetStruct, nTest);

smartChosenTestRange = [];
smartSkippedTestRange = [];
smartLeftTestRange = testRange;

%% remainingBudget = budgets(end);
totalUsedBudget = 0;
newWeCanAsk = 0;

while ~isempty(smartLeftTestRange) && totalUsedBudget<=totalBudget
    fprintf(1,'%d \n', totalUsedBudget);
    
    whatYouCanLookAt = smartLeftTestRange(1:min(whatYouCanSee, length(smartLeftTestRange)));
    
    choiceTime = tic;
    [newChosenIdx, newChosenWeights] = activeLearner.chooseItems(whatYouCanLookAt, cm.getDataWeights([trainRange; smartChosenTestRange]), ...
                              cm.getData([trainRange; smartChosenTestRange]), ...
                              [cm.getRealLabels(trainRange); cm.getCrowdLabels(smartChosenTestRange)], ...
                              cm.getData(whatYouCanLookAt), newWeCanAsk);
    thisChoiceTime = toc(choiceTime);
    
    smartChosenTestRange = [smartChosenTestRange; newChosenIdx];
    cm.updateDataWeights(newChosenIdx, newChosenWeights);
    smartLeftTestRange = setdiff(smartLeftTestRange, newChosenIdx);
    if activeLearner.scoresEachItemOnlyOnce
        skipped = setdiff(whatYouCanLookAt, newChosenIdx);
        smartLeftTestRange = setdiff(smartLeftTestRange, skipped);
        smartSkippedTestRange = [smartSkippedTestRange; skipped];
    end
    assert(newWeCanAsk==0 || length(newChosenIdx)>0 || activeLearner.scoresEachItemOnlyOnce); % otherwise we're in an infinite loop!

    eMgr.recordActiveAction(trainRange, smartChosenTestRange, [smartSkippedTestRange; smartLeftTestRange], newChosenIdx, thisChoiceTime);
    
    totalUsedBudget = length(smartChosenTestRange);
    randChosenTestRange = testRange(1:totalUsedBudget);
    randLeftTestRange = setdiff(testRange, randChosenTestRange);

    eMgr.recordPassiveAction(trainRange, randChosenTestRange, randLeftTestRange);
    
    newWeCanAsk = min([budgetPerStep whatYouCanSee length(smartLeftTestRange)]); 
end

fprintf(1,'end of repetition %d \n', experimentId);
end % This is the end of each repetition!

[avgImprovement, relAvgImprovement] = eMgr.finalSaveToFile('ModelError', 'F1measure');
msg = 'hello world!';

end


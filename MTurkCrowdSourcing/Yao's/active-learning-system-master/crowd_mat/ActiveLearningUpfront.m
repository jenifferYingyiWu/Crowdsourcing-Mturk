function [ output_args ] = ActiveLearningUpfront(datasetConfig, activeLearner, budgetStruct, randSeed, repetitionFactor, resultFileName)
%(primaryKeyCol, classCol, crowdUserCols, crowdLabelCols, featureCols, fakeCrowd, balancedLabels, initialTrainRatio, budgetStruct, ranker, rankerOptions, resultFileName)
overallTime = tic;

[algRand, cmRand, baseLineRand] = computeRandSeeds(randSeed, false);
RandStream.setGlobalStream(algRand);
activeLearner.randStream = algRand;

for experimentId=1:repetitionFactor
cm = CrowdManager(datasetConfig.datafile, datasetConfig.primaryKeyCol, datasetConfig.classCol, datasetConfig.crowdUserCols, datasetConfig.crowdLabelCols, datasetConfig.featureCols, datasetConfig.fakeCrowd, datasetConfig.balancedLabels, cmRand, true);

totalSize = cm.numberOfItems;

%split into train and test
split = round(totalSize * datasetConfig.initialTrainRatio);
trainRange = (1:(split-1))';
testRange = (split:totalSize)';

nTest = length(testRange);
nTrain = length(trainRange);
trainWeights = ones(nTrain, 1);
smartTestWeights = ones(nTest, 1);

% these are the answers we would get from the crowd!
predictedTestLabel = activeLearner.learner.trainPredict(trainWeights, cm.getData(trainRange), cm.getRealLabels(trainRange), cm.getData(testRange));

%getting the ranking!
ranking = activeLearner.calculateScores(trainWeights, cm.getData(trainRange), cm.getRealLabels(trainRange), cm.getData(testRange));

%let's sort our test data according to our ranking and pick the ones with
%the largest scores
temp = [ranking testRange predictedTestLabel];
temp = sortrows(temp, -1);  
sortedTestRange = temp(:,2);
sortedPredictedTestLabel = temp(:,3);

%what would happen if we were allowed to ask fixed number of questions
[budgets budgetStep] = computeBudgets(budgetStruct, nTest);

errorUpfrontBaseline = zeros(length(budgets),3,5);
errorUpfrontSmart = zeros(length(budgets),3,5);
CrowdIdx = 1; ModelIdx = 2; OverallIdx = 3;
whatToShow = ModelIdx;
% initialize them with -1 to determine the real zero error from un-assigned values.
errorUpfrontBaseline(:,:,:) = -1;
errorUpfrontSmart(:,:,:) = -1;

for budgetIdx=1:length(budgets)
    howManyCanWeAsk = budgets(budgetIdx);
    
    smartPrediction = [cm.getCrowdLabels(sortedTestRange(1:howManyCanWeAsk)); sortedPredictedTestLabel(howManyCanWeAsk+1:end,:)];
    errorUpfrontSmart(budgetIdx, :, :) = bin3ClassError(smartPrediction, cm.getRealLabels(sortedTestRange), howManyCanWeAsk);

    sillyPrediction = [cm.getCrowdLabels(testRange(1:howManyCanWeAsk)); predictedTestLabel(howManyCanWeAsk+1:end,:)];
    errorUpfrontBaseline(budgetIdx, :, :) = bin3ClassError(sillyPrediction, cm.getRealLabels(testRange), howManyCanWeAsk);
end

if experimentId==1
    SUMerrorUpfrontBaseline = zeros([repetitionFactor size(errorUpfrontBaseline)]);
    SUMerrorUpfrontSmart = zeros([repetitionFactor size(errorUpfrontSmart)]);
end
SUMerrorUpfrontBaseline(experimentId,:,:,:) = errorUpfrontBaseline;
SUMerrorUpfrontSmart(experimentId,:,:,:) = errorUpfrontSmart;

fprintf(1,'end of repetition %d \n', experimentId);
end % This is the end of each repetition!

errorUpfrontBaseline(:,:,:) = nanmean(SUMerrorUpfrontBaseline,1);
errorUpfrontSmart(:,:,:) = nanmean(SUMerrorUpfrontSmart,1);

runningTime = toc(overallTime);

save(resultFileName, 'activeLearner', 'datasetConfig', 'budgetStruct', 'runningTime', 'repetitionFactor');
save(resultFileName, 'errorUpfrontBaseline', 'errorUpfrontSmart', '-append');

fprintf(1,'elapsed time=%f\n', runningTime);


fh = figure('Name', [datasetConfig.datafile ' : ' activeLearner.fullName],'Color',[1 1 1]);
set(0,'defaultaxesfontsize',20);
set(0,'defaultlinelinewidth',3);

plot(errorUpfrontBaseline(:,whatToShow,1), errorUpfrontBaseline(:,whatToShow, 2), 'b*:', 'DisplayName', 'UpfrontBaseline');
hold all;
legend('-DynamicLegend');
plot(errorUpfrontSmart(:,whatToShow,1), errorUpfrontSmart(:,whatToShow, 2), 'g+:', 'DisplayName', strcat('UpfrontSmart(', activeLearner.fullName,')'));

xlabel('#number of questions asked, all at once!');
ylabel('Accuracy: ratio of correctly-classified.');

hgsave(fh, strcat(resultFileName,'.fig'));
print(fh,'-djpeg', strcat(resultFileName,'.jpg'));
print(fh,'-deps', strcat(resultFileName,'.eps'));

%close(fh);


end


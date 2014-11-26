function [ output_args ] = predictError(repetitionFactor, learner, randSeed, Dataset, classIndex, crowdIndex, initialTrainRatio, QuestionBatchSize, ranker, rankerOptions, errorEstimator, resultFileName)

overallTime = tic;

randStream = RandStream('mt19937ar','seed', randSeed);

for experimentId=1:repetitionFactor
%shuffle
rndIdx = randperm(randStream, size(Dataset,1));
Dataset = Dataset(rndIdx,:);

%%
%Dataset = Dataset(1:20,:);

totalSize = size(Dataset,1);
featureCols = 1:size(Dataset,2);
featureCols = featureCols(featureCols ~= classIndex & featureCols ~= crowdIndex);

%split into train and test
split = round(totalSize * initialTrainRatio);
trainRange = 1:(split-1);
testRange = split:totalSize;

trainData = Dataset(trainRange, featureCols);
trainLabel = Dataset(trainRange, classIndex);
testData = Dataset(testRange, featureCols);
testLabel = Dataset(testRange, classIndex);
crowdLabel = Dataset(testRange, crowdIndex); 

nTest = size(testData,1);
nTrain = size(trainData, 1);

% these are the initial predictions based on our original set of perfect labels
predictedTestLabel = learner(trainData, trainLabel, testData, 0);

%what would happen if we were allowed to ask a fixed number of questions, i.e. our budget.
budgets = [0:QuestionBatchSize:nTest]';
if budgets(end)~=nTest
    budgets = [budgets; nTest];
end
errorSillyEstimates = zeros(length(budgets), 3, 5);
ActualOverallIdx = 1; ActualModelIdx = 2; EstimateIdx = 3;
% initialize them with -1 to determine the real zero error from un-assigned values.
errorSillyEstimates(:,:,:) = -Inf;

augTrainData = trainData;
augTrainMixedLabel = trainLabel;
augTrainPerfectLabel = trainLabel;
leftTestData = testData;
leftTestLabel = testLabel;
leftCrowdLabel = crowdLabel;

for budgetIdx=1:length(budgets)
    totalWeCanAsk = budgets(budgetIdx);
    if budgetIdx>=2
        newWeCanAsk = totalWeCanAsk-budgets(budgetIdx-1);
    else
        newWeCanAsk = totalWeCanAsk;
    end
    
    fprintf(1,'%d \n', totalWeCanAsk);
      
    sillyIterativePrediction = crowdLabel;
    sillyIterativePrediction(totalWeCanAsk+1:end,:) = learner([trainData; testData(1:totalWeCanAsk,:)], [trainLabel; crowdLabel(1:totalWeCanAsk,:)], testData(totalWeCanAsk+1:end,:), 0); 
    [miss rec prec fscore] = binClassError(sillyIterativePrediction(totalWeCanAsk+1:end,:), testLabel(totalWeCanAsk+1:end,:));
    errorSillyEstimates(budgetIdx, ActualModelIdx,  :) = [totalWeCanAsk miss rec prec fscore];
    [miss rec prec fscore] = binClassError(sillyIterativePrediction, testLabel);
    errorSillyEstimates(budgetIdx, ActualOverallIdx,  :) = [totalWeCanAsk miss rec prec fscore];
    [miss rec prec fscore] = errorEstimator(learner, trainData, trainLabel, testData(1:totalWeCanAsk,:), crowdLabel(1:totalWeCanAsk,:), testData(totalWeCanAsk+1:end,:));   
    errorSillyEstimates(budgetIdx, EstimateIdx,  :) = [totalWeCanAsk miss rec prec fscore];
  
    %getting the confidence intervals!
    ranking = ranker(learner, augTrainData, augTrainMixedLabel, leftTestData, 0, rankerOptions);
    for minIdx=1:newWeCanAsk
        [v idx] = max(ranking);
        augTrainData = [augTrainData; leftTestData(idx,:)];
        augTrainPerfectLabel = [augTrainPerfectLabel; leftTestLabel(idx,1)];
        augTrainMixedLabel = [augTrainMixedLabel; leftCrowdLabel(idx,1)];            
        remainingIdx = [1:(idx-1) (idx+1):size(leftTestData,1)];
        leftTestData = leftTestData(remainingIdx,:);
        leftTestLabel = leftTestLabel(remainingIdx,:);
        leftCrowdLabel = leftCrowdLabel(remainingIdx,:);
        ranking = ranking(remainingIdx,:);
    end
    
    predictedLeftTestLabel = learner(augTrainData, augTrainMixedLabel, leftTestData, 0);
    %let's sort our test data according to our confidence measure. We
    %consider it from nTrain+1 since the first nTrain points were our
    %training data
    [miss rec prec fscore] = binClassError([predictedLeftTestLabel], [leftTestLabel]);
    errorSmartEstimate(budgetIdx, ActualModelIdx, :) = [totalWeCanAsk miss rec prec fscore];
    [miss rec prec fscore] = binClassError([augTrainMixedLabel(nTrain+1:end,1); predictedLeftTestLabel], [augTrainPerfectLabel(nTrain+1:end,1); leftTestLabel]);
    errorSmartEstimate(budgetIdx, ActualOverallIdx, :) = [totalWeCanAsk miss rec prec fscore];
    [miss rec prec fscore] = errorEstimator(learner, trainData, trainLabel, augTrainData(nTrain+1:end,:), augTrainMixedLabel(nTrain+1:end,:), leftTestData);   
    errorSmartEstimate(budgetIdx, EstimateIdx,  :) = [totalWeCanAsk miss rec prec fscore];
    
    save(resultFileName, 'errorSillyEstimates', 'errorSmartEstimate', 'experimentId');
end
errorSillyEstimates = errorSillyEstimates(errorSillyEstimates(:,1,1)~=-Inf,:,:);
errorSmartEstimate = errorSmartEstimate(errorSmartEstimate(:,1,1)~=-Inf,:,:);

if experimentId==1
    SUMerrorSillyEstimates = zeros([repetitionFactor size(errorSillyEstimates)]);
    SUMerrorSmartEstimate = zeros([repetitionFactor size(errorSmartEstimate)]);
end

SUMerrorSillyEstimates(experimentId,:,:,:) = errorSillyEstimates;
SUMerrorSmartEstimate(experimentId,:,:,:) = errorSmartEstimate;

fprintf(1,'end of repetition %d \n', experimentId);
end % This is the end of each repetition!

errorSillyEstimates(:,:,:) = nanmean(SUMerrorSillyEstimates,1);
errorSmartEstimate(:,:,:) = nanmean(SUMerrorSmartEstimate,1);

save(resultFileName, 'learner', 'classIndex', 'crowdIndex', 'initialTrainRatio', 'QuestionBatchSize', 'ranker', 'rankerOptions', 'errorEstimator');
save(resultFileName, 'errorSillyEstimates', 'errorSmartEstimate', '-append');

fh = figure('Name', [func2str(errorEstimator) ':'  func2str(ranker)],'Color',[1 1 1]);
set(0,'defaultaxesfontsize',20);
set(0,'defaultlinelinewidth',3);

plot(errorSillyEstimates(:, ActualModelIdx, 1), errorSillyEstimates(:, ActualModelIdx, 2), 'b*', 'DisplayName', 'Actual Baseline (model)');
hold all;
legend('-DynamicLegend');
%plot(errorSillyEstimates(:, ActualOverallIdx, 1), errorSillyEstimates(:, ActualOverallIdx, 2), 'b-', 'DisplayName', 'Actual Baseline (overall)');
plot(errorSillyEstimates(:, EstimateIdx, 1), errorSillyEstimates(:, EstimateIdx, 2), 'b:', 'DisplayName', 'Estimated Baseline');

%plot(errorSmartEstimate(:, ActualModelIdx, 1), errorSmartEstimate(:, ActualModelIdx, 2), 'r*', 'DisplayName', ['Actual ' func2str(ranker) ' (model)']);
%plot(errorSmartEstimate(:, ActualOverallIdx, 1), errorSmartEstimate(:, ActualOverallIdx, 2), 'r-', 'DisplayName', ['Actual ' func2str(ranker) ' (overall)']);
%plot(errorSmartEstimate(:, EstimateIdx, 1), errorSmartEstimate(:, EstimateIdx, 2), 'r:', 'DisplayName', ['Estimated ' func2str(ranker) ' ']);

xlabel(strcat('Total # of questions, asked  ',num2str(QuestionBatchSize), ' at a time'));
ylabel('Accuracy: ratio of correctly-classified.');

hgsave(fh, strcat(resultFileName,'.fig'));
print(fh,'-djpeg', strcat(resultFileName,'.jpg'));
print(fh,'-deps', strcat(resultFileName,'.eps'));

close(fh);

elapsed = toc(overallTime);
fprintf(1,'elapsed time=%f\n',elapsed);


end


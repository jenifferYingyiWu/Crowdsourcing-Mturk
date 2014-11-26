function [accuracy recall precision f1_measure] = errEstimateCrowdErr(learner, trainData, trainLabel, crowdData, crowdLabel, testData)
% learner is the learning algorithm
% trainData is the entire data for which the model can use the ground truth
% labels for, which is the trainLabel
% crowdData and crowdLabel are the entire crowd data
% testData is the unlabeled data

if size(trainData, 1)~=size(trainLabel, 1) || size(crowdData, 1) ~= size(crowdLabel, 1) || size(trainData, 2) ~= size(crowdData, 2) || size(trainData, 2) ~= size(testData, 2)
    error('dimension mismatch');
end

predictedTrainLabel = learner([trainData; crowdData], [trainLabel; crowdLabel], [crowdData], 0);

[accuracy recall precision f1_measure] = binClassError(predictedTrainLabel, [crowdLabel]);

end


function [accuracy recall precision f1_measure] = errEstimateTrainCrowdCrossVal(learner, trainWeights, trainData, trainLabel, crowdWeights, crowdData, crowdLabel, testData, randStream)
% learner is the learning algorithm
% trainData is the entire data for which the model can use the ground truth
% labels for, which is the trainLabel
% crowdData and crowdLabel are the entire crowd data
% testData is the unlabeled data

if size(trainData, 1)~=size(trainLabel, 1) || size(crowdData, 1) ~= size(crowdLabel, 1) || size(trainData, 2) ~= size(crowdData, 2) || size(trainData, 2) ~= size(testData, 2)
    error('dimension mismatch');
end


f = @(x,y)learner.trainPredict(x(:,1:end-1),x(:,end),y(:,1:end-1));
%g = @(x,y)binClassError(f(x,y), y(:,end));
%vals = crossval(g, A, 'kfold', 5);

A = [trainWeights trainData trainLabel; crowdWeights crowdData crowdLabel];
nRows = size(A,1);

nFolds = min(10, nRows);

vals = zeros(nFolds, 4);

if 1==0 % use matlab's partitioning mechanims (which is bad because it doesn't take a random seed
    partitions = cvpartition(nRows, 'k', nFolds);
    parfor i=1:nFolds
       trainA = A(partitions.training(i),:);
       testA = A(partitions.test(i),:);
       [v1, v2, v3, v4] = binClassError(learner.trainPredict(trainA(:,1), trainA(:,2:end-1),trainA(:,end), testA(:,2:end-1)), testA(:,end));
       vals(i,:) = [v1 v2 v3 v4];
    end
else % use our own partitioning
    allIdx = randperm(randStream, nRows);
    partSize = floor(nRows/nFolds);
    partitions = zeros(nRows, 1);
    for i=1:nFolds
        range = ((i-1)*partSize+1):(i*partSize);
        partitions(allIdx(range)) = i;        
    end
    nRemaining = nRows-nFolds*partSize;
    partitions(partitions==0) = randperm(randStream, nRemaining);

    parfor i=1:nFolds
       trainA = A(partitions~=i,:);
       testA = A(partitions==i,:);
       [v1, v2, v3, v4] = binClassError(learner.trainPredict(trainA(:,1), trainA(:,2:end-1),trainA(:,end), testA(:,2:end-1)), testA(:,end));
       vals(i,:) = [v1 v2 v3 v4];
    end
end

errs = nanmean(vals, 1);
accuracy = errs(1);
recall = errs(2);
precision = errs(3);
f1_measure = errs(4);

end


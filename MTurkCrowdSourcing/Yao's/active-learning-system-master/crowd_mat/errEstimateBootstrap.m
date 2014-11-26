function [errEstimate ok1 ok2 ok3] = errEstimateBootstrap(learner, trainWeights, trainData, trainLabel, crowdWeights, crowdData, crowdLabel, testData, randStream)
%we want to return:
%Pr[actuallabel_of_u=x]*E(T+(u,x),T+(u,x)) + (1-Pr[actuallabel_of_u=x])*E(T+(u,x),T+(u,1-x))

trainWeights = [trainWeights; crowdWeights];
trainData = [trainData; crowdData];
trainLabel = [trainLabel; crowdLabel];

nTest = size(testData,1);
nTrain = size(trainData,1);
nBoots = 10;
bootVals = zeros(nTest, nBoots);

%train_err = zeros(nTest, 2);
prob_being_right = zeros(nTest, 1);
expectedTrainingError  = zeros(nTest, 1);

currentPredictions = learner.trainPredict(trainWeights, trainData, trainLabel, testData); 

parfor b=1:nBoots
    fprintf(1,'B-%d ', b);
    ind = randsample(randStream, nTrain, nTrain, true);
    trainWeightsBS = trainWeights(ind,:);
    trainDataBS = trainData(ind,:);
    trainLabelBS = trainLabel(ind,:);
    bootVals(:,b) = learner.trainPredict(trainWeightsBS, trainDataBS, trainLabelBS, testData); 
end

parfor i=1:nTest
%bstat = bootVals(i,:);
%se = std(bstat,0,1);   % standard deviation estimate
%bias = mean(bsxfun(@minus,bstat,stat),1);
%za = norminv(alpha/2);   % normal confidence point
%lower = stat - bias + se*za; % lower bound
%upper = stat - bias - se*za;  % upper bound    
    numOfPred1 = sum(bootVals(i,:));
    numOfPred0 = nBoots - numOfPred1;
    if currentPredictions(i,1)==1
        prob_being_right(i,1) = numOfPred1/nBoots; 
    else
        prob_being_right(i,1) = numOfPred0/nBoots; 
    end
end

errEstimate = 1 - mean(prob_being_right);
ok1 = NaN;
ok2 = NaN;
ok3 = NaN;
% warning('You are calling a function that returns null no matter what the input!');
end


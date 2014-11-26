randSeed = 1024;
learner = @bClassify;
repFactor = 20;

nboots = 10;
reso = 5;
initTrain = 0.03;
dataset=load('crab.dat');
classIndex=7;
crowdIndex=7;

matlabpool close force;
matlabpool open;

%% One Step at a time
runAllOneSteps;


%% Iterative
runAllIteratives;

fprintf(1,'All finished.\n');

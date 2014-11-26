randSeed = 123456789;
initTrain = 1;
datafile='small-entity2.dat';

primaryKeyCol = 1;
classCol = 2;
crowdUserCols = 3:2:8;
crowdLabelCols = 4:2:8;
featureCols = 9:12;
fakeCrowd = true;
balancedLabels = false; 

%matlabpool close force;
%matlabpool open;
    
cm = CrowdManager(datafile, primaryKeyCol, classCol, crowdUserCols, crowdLabelCols, featureCols, fakeCrowd, balancedLabels);
totalSize = cm.numberOfItems;
allRange = 1:totalSize;

budgets = (1:100:700)';
bgs = length(budgets);

    split =round(totalSize * initTrain);
    trainRange = randsample(allRange, (split-1), false);
    testRange = setdiff(allRange, trainRange);

    trainRange = repmat(trainRange, 1, 1);
    testRange = repmat(testRange, 1, 1);
    
    nTest = length(testRange);
    nTrain = length(trainRange);

    trainData = cm.getData(trainRange);
    trainLabel_1 = cm.getRealLabels(trainRange);    
    trainLabel_2 = 2*trainLabel_1 -1; 
    testData = cm.getData(testRange);
    testLabel_1 = cm.getRealLabels(testRange);
    testLabel_2 = 2*testLabel_1 - 1;

    
D = sparse(trainData);
L = trainLabel_1;

pp = 600;
D2 = sparse(trainData(1:pp,:));
L2 = trainLabel_1(1:pp, :);

D1 = sparse(trainData(pp+1:end, :));
L1 = trainLabel_1(pp+1:end, :);

model = lltrain(L, D, '-s 0 -c 20'); ok1 = llpredict(L, D, model); [min(ok1) max(ok1) sum(ok1) length(ok1)]

model = lltrain(L1, D1, '-s 0 -c 20'); ok2 = llpredict(L, D, model); [min(ok2) max(ok2) sum(ok2) length(ok2)]

new_model = inc_lltrain(model, L2, D2, '-s 0 -c 20'); ok = llpredict(L, D, new_model); [min(ok) max(ok) sum(ok) length(ok)]


    
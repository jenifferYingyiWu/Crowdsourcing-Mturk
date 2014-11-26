randSeed = 123456789;
initTrain = 1;
datafile='entity2.dat';

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

budgets = (1:100:1000)';
bgs = length(budgets);
nReps = 1;
time = zeros(nReps, bgs, 3);
accuracy = zeros(nReps, bgs, 3);

firstBatch = 500;
for rep=1:nReps

    %split into train and test
    split =round(totalSize * initTrain);
    trainRange = randsample(allRange, (split-1), false);
    testRange = setdiff(allRange, trainRange);

    trainRange = repmat(trainRange, 1, 10);
    testRange = repmat(testRange, 1, 1);
    
    nTest = length(testRange);
    nTrain = length(trainRange);

    trainData = cm.getData(trainRange);
    trainLabel_1 = cm.getRealLabels(trainRange);    
    trainLabel_2 = 2*trainLabel_1 -1; 
    testData = cm.getData(testRange);
    testLabel_1 = cm.getRealLabels(testRange);
    testLabel_2 = 2*testLabel_1 - 1;
    
    %%
    D1 = sparse(trainData(end-firstBatch+1:end, :));
    L1 = trainLabel_1(end-firstBatch+1:end, :);
    for i=1:bgs
        bud = budgets(i);
        D2 = sparse(trainData(1:bud, :));
        L2 = trainLabel_1(1:bud, :);
        ts = tic;
%        ypred_1 = sClassify(D1, L1, D1, 0);
%        ypred_1 = sClassify([D1; D2], [L1; L2], [D1; D2], 0);
        
        [ypred_1 model1] = incSClassify(D1, L1, D1, 0);
        [ypred_1 model2] = incSClassify([D1; D2], [L1; L2], [D1; D2], 0);
        
        tst = toc(ts);            
        time(rep, i, 1:2) = [bud tst];
        [acc recall precision f1_measure] = binClassError(ypred_1, [L1; L2]); 
        accuracy(rep, i, 1:2) = [bud acc];

    end

    %%
    D1 = sparse(trainData(end-firstBatch+1:end, :));
    L1 = trainLabel_2(end-firstBatch+1:end, :);
    for i=1:bgs
        bud = budgets(i);
        D2 = sparse(trainData(1:bud, :));
        L2 = trainLabel_2(1:bud, :);
        ts = tic;
        %myC = 0.5;
        %myType = 1;
        %myScale = 1;
        %model = inc_svm;
        %inc_svmtrain2(model, D1, L1, myC, myType, myScale);
        %ypred_2 = inc_svmeval(model, testData);
        %inc_svmtrain2(model, D2, L2, myC);
        %ypred_2 = inc_svmeval(model, testData);    
        [ypred_2 model1] = incSClassify(D1, L1, D1, 0);
        [ypred_2 model2] = incSClassify([D1; D2], [L1; L2], [D1; D2], 0, model1);

%        model1 = lltrain(L1, D1, '-s 0 -c 20')
%        [ypred_1, a1]= llpredict(L1, D1, model1);
 %       model2 = inc_lltrain(model1, L2, D2, '-s 0 -c 20');
  %      [ypred_2, a2] = llpredict([L1; L2], [D1; D2], model2);
        tst = toc(ts);
        time(rep, i, 3) = tst;
        [acc recall precision f1_measure] = binClassError(ypred_2, [L1; L2]);
        accuracy(rep, i, 3) = acc;        
    end
end

things = {'time', 'accuracy'};

for which=1:length(things)
    subplot(1,2, which);
    A = mean(eval(things{which}), 1);
        
    B = zeros(bgs, 3);
    B(:,:) = A(1,:,:); 
    X = B(:,1);
    Y = B(:,2:3);
    bar(X, Y);
    title('Batch Training of SVM');
    xlabel('Training Size');
    ylabel(things{which});
    legend('Batch SVM', 'incremental SVM');
    %set(gca,'YScale','log');

    ok = axis;
    ok(4)=ok(4)*1.1;
    axis(ok)
    for i=1:length(X)
        text(X(i), Y(i,1)+min(Y(:,1))*10, num2str(Y(i,1)));
        text(X(i), Y(i,2)+min(Y(:,2))*10, num2str(Y(i,2)));
    end
    save(['/tmp/which' num2str(which)], 'B', '-ascii');
    nanmean(Y)
end


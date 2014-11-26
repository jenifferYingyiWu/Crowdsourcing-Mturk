%CMU Face dataset
isStraight =2; isLeft=3; isRight=4; isUp=5; isOpen=6; isSunglasses=7; isNeutral=8; isHappy=9; isSad=10; isAngry=11;

cmu_sunglass_conf = struct('initTrain', 0.11, 'learner', @vrClassify, 'datafile', 'face4.vis', 'classCol', isSunglasses, 'featureCols',  11+[1:(3+15360)]);
cmu_neutral_conf = struct('initTrain', 0.11, 'learner', @vrClassify, 'datafile', 'face4.vis', 'classCol', isNeutral, 'crowdUserCols', 2:5:46, 'crowdLabelCols', 3:5:46, 'fakeCrowd', false, 'featureCols', 11+[1:(3+15360)]);
cmu_happy_conf = struct('initTrain', 0.11, 'learner', @vrClassify, 'datafile', 'face4.vis', 'classCol', isHappy, 'crowdUserCols', 2:5:46, 'crowdLabelCols', 4:5:46, 'fakeCrowd', false, 'featureCols', 11+[1:(3+15360)]);
cmu_sad_conf = struct('initTrain', 0.11, 'learner', @vrClassify, 'datafile', 'face4.vis', 'classCol', isSad, 'crowdUserCols', 2:5:46, 'crowdLabelCols', 5:5:46, 'fakeCrowd', false, 'featureCols', 11+[1:(3+15360)]);
cmu_angry_conf = struct('initTrain', 0.11, 'learner', @vrClassify, 'datafile', 'face4.vis', 'classCol', isAngry, 'crowdUserCols', 2:5:46, 'crowdLabelCols', 6:5:46, 'fakeCrowd', false, 'featureCols', 11+[1:(3+15360)]);

%%%%%%%%%%%
    config = cmu_neutral_conf;
    if isfield(config, 'repFactor')
        repFactor = config.repFactor;
    else
        repFactor = 10;
    end
    if isfield(config, 'primaryKeyCol')
        primaryKeyCol = config.primaryKeyCol;
    else
        primaryKeyCol = 1;
    end
    if isfield(config, 'classCol')
        classCol = config.classCol;
    else
        classCol = 2;
    end
    if isfield(config, 'crowdUserCols')
        crowdUserCols = config.crowdUserCols;
    else
        crowdUserCols = [];
    end
    if isfield(config, 'crowdLabelCols')
        crowdLabelCols = config.crowdLabelCols;
    else
        crowdLabelCols = [];
    end
    if isfield(config, 'fakeCrowd')
        fakeCrowd = config.fakeCrowd;
    else
        fakeCrowd = true;
    end
    if isfield(config, 'balancedLabels')
        balancedLabels = config.balancedLabels;
    else
        balancedLabels = false;
    end
    if isfield(config, 'initTrain')
        initTrain = config.initTrain;
    else
        initTrain = 0.03;
    end
    if isfield(config, 'useWeightedSampling')
        useWeightedSampling = config.useWeightedSampling;
    else
        useWeightedSampling = true;
    end
    if isfield(config, 'rankerOpt')
        rankerOpt = config.rankerOpt;
    else
        rankerOpt = struct('nboots', 10, 'alpha', 0.05, 'type', 'norm');
    end
    if isfield(config, 'reso')
        reso = config.reso;
    else
        reso = struct('absolute_steps', false, 'steps', 0.1, 'absolute_last', false, 'last', 1);
    end
    if isfield(config, 'iidBatchRatio')
        iidBatchRatio = config.iidBatchRatio;
    else
        iidBatchRatio = 2;
    end
    if isfield(config, 'learner')
        learner = config.learner;
    else
        learner = @incSClassify;
        %learner = @nClassify;
        %learner = @tClassify;
        %learner = @nClassify;
        %learner = @bClassify;
    end
    datafile = config.datafile;
    featureCols = config.featureCols;
    
    randSeed = 12345;
%    cmRand = RandStream('mt19937ar','seed', randSeed+1);
    cmRand = RandStream('mt19937ar');

%%%

cm = OptimalCrowdManager(datafile, primaryKeyCol, classCol, crowdUserCols, crowdLabelCols, featureCols, fakeCrowd, balancedLabels, cmRand, true);

isStraight =2; isLeft=3; isRight=4; isUp=5; isOpen=6; isSunglasses=7; isNeutral=8; isHappy=9; isSad=10; isAngry=11;
%attributeIdx = [isStraight isLeft isRight isUp];
%attributeIdx = [isStraight isLeft isRight isUp isOpen isSunglasses];
%attributeIdx = [isOpen isSunglasses];
attributeIdx = [];

initialRowsPerGroup = 150;
initialRowsPerGroup = 2;
initialRedundancy = 9;
removeInitialItems = false;
useProjected = true;

[estimated_error userPerGroupErrorProb actual_error howManyGroups howManyInEachGroup groups groupsKey] = ...
    cm.estimateWorkerAccuracies(attributeIdx, initialRowsPerGroup, initialRedundancy, removeInitialItems, useProjected);

if ~useProjected
    err = actual_error;
else
    err = estimated_error;
end

baseName = ['cls-' num2str(config.classCol) '-attr-' num2str(length(attributeIdx)) '-projected-'];
exprName = [baseName num2str(useProjected)];
[budgets sillyError smartError optimalAssignmentPerGroup] = cm.solveOptimalAllocation(err, howManyInEachGroup, groupsKey);

save([exprName '.mat'], 'budgets', 'sillyError', 'smartError', 'estimated_error', 'userPerGroupErrorProb', 'actual_error', 'howManyInEachGroup', 'groupsKey', 'optimalAssignmentPerGroup', 'initialRowsPerGroup', 'initialRedundancy', 'removeInitialItems', 'useProjected');

ourError = zeros(size(optimalAssignmentPerGroup,2), 1);
for avgAllowedRedundancy=1:size(optimalAssignmentPerGroup,2)
    howManyLabelsEach = zeros(cm.numberOfItems,1);
    for gid=1:howManyGroups
        howManyLabelsEach(groups(gid,1:howManyInEachGroup(gid)),1) = optimalAssignmentPerGroup(gid,avgAllowedRedundancy);
    end
    assert(all(howManyLabelsEach>0));
    assert(sum(howManyLabelsEach)<=avgAllowedRedundancy*cm.numberOfItems);
    cl = cm.getCrowdLabels(1:cm.numberOfItems, howManyLabelsEach);
    rl = cm.getRealLabels(1:cm.numberOfItems);
    ourError(avgAllowedRedundancy) = 1-binClassError(cl,rl);
end


%baseName = ['cls-' num2str(config.classCol) '-attr-' num2str(length(attributeIdx)) '-projected-'];

fontsize = 16;
fontweight = 'bold';
set(0,'defaultaxesfontsize', fontsize);
set(0,'defaultaxesfontweight', fontweight);
set(0,'defaultlinelinewidth',2);

fh = figure('Color',[1 1 1], 'Name', baseName);
actual = load([baseName '0']);
projected = load([baseName '1']);

plot(actual.budgets, actual.sillyError, 'b+-');
hold on;
plot(projected.budgets, projected.sillyError, 'b:o');
plot(actual.budgets, ourError, 'g+-');
plot(projected.budgets, projected.smartError, 'g:o');
plot(actual.budgets, actual.smartError, 'r:o');

xlabel('total # of questions / total # of unlabeled items');
ylabel('Crowd''s Error (majority vote)');
legend('Uniform in reality', 'Uniform (projected)', 'PBA in reality', 'PBA (projected)', 'Optimal (PBA w/ perfect info)');

hgsave(fh, [baseName '.fig']);


ok = 1;  
clear cm;
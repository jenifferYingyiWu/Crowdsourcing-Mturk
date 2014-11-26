function [ output_args ] = compareClassifiers(datasetsIcare, classifiersIcare, freshLearning, incrementalLearning, setRandomWeights)
import java.util.*;
overallTime = tic;

if nargin < 2
    classifiersIcare = {};
end

if nargin < 3
    freshLearning = true;
end

if nargin < 4
    incrementalLearning = false;
end

if nargin < 5
    setRandomWeights = false;
end


init_dataset_configs

datasets = {...
    'entity_small_perfect', 'entity_small_crowd', 'entity_small_qt_crowd', ...
    'entity_perfect', 'entity_crowd', 'entity_qt_crowd', ...
    'iris', 'segmentation', 'haberman', 'ionosphere',...  %small ones
    'parkinsons', 'glass', 'vertebral_column', ...        %small ones 
    'cancer', 'mammographic_masses', 'steel_plates_faults', ... % big ones
    'transfusion', 'vehicle', 'optdigits', ... % big ones
    'pima_indians_diabetes', 'yeast', 'spambase', ...  % big ones
    'cmu_sunglass', ... %'cmu_neutral', 'cmu_happy', 'cmu_sad', 'cmu_angry', 
    'caltech_gender', ...
    'caltech_humanface', ...
    'caltech_lobster', ...
    'tweets_10k', ...
    'tweets_100k' ...
    };


classifier_classes = java.util.Hashtable;
classifier_classes.put('bClassifier', nan);
%classifier_classes.put('pegasosClassifier', nan);
classifier_classes.put('incSClassifier', nan);
%classifier_classes.put('nClassifier', nan);
classifier_classes.put('sClassifier', nan);
classifier_classes.put('sClassifierFast', nan);
%classifier_classes.put('vrClassifier', nan);
%classifier_classes.put('tClassifier', nan);
classifier_classes.put('twClassifier', nan);


if isempty(classifiersIcare)
    classifierIter = ArrayList(classifier_classes.keySet).iterator();
    while classifierIter.hasNext()
        classifierName = classifierIter.next();
        classifiersIcare{end+1} = classifierName;
    end
end

randSeed = 12345; % -1 means do not change the random seed every time!

nCores = feature('numCores')
if nCores > 2
    if matlabpool('size')~=nCores
        defaultProfile = parallel.defaultClusterProfile;
        myCluster = parcluster(defaultProfile);
        matlabpool(myCluster, 'open');
    end
end

for dsiter=1:length(datasets)
    ds = datasets{dsiter};
    if ~isempty(datasetsIcare) && ~ismember(ds, datasetsIcare); continue; end
    datasetConfig = eval([ds '_conf']);

    repFactor = 1;
    
    if ~isfield(datasetConfig, 'primaryKeyCol')
        datasetConfig.primaryKeyCol = 1;
    end
    if ~isfield(datasetConfig, 'classCol')
        datasetConfig.classCol = 2;
    end
    if ~isfield(datasetConfig, 'crowdUserCols')
        datasetConfig.crowdUserCols = [];
    end
    if ~isfield(datasetConfig, 'crowdLabelCols')
        datasetConfig.crowdLabelCols = [];
    end
    if ~isfield(datasetConfig, 'fakeCrowd')
        datasetConfig.fakeCrowd = true;
    end
    if ~isfield(datasetConfig, 'balancedLabels')
        datasetConfig.balancedLabels = false;
    end
    if ~isfield(datasetConfig, 'initialTrainRatio')
        datasetConfig.initialTrainRatio = 0.03;
    end
    if ~isfield(datasetConfig, 'datafile')
        datasetConfig.datafile = [ds '.vis'];
    end
    if ~isfield(datasetConfig, 'featureCols');
        error(['Unknown feature set for' ds]);
    end

    %typical batching iterative
    %batchingStrategy = struct('score_each_item_only_once', NaN, 'absolute_windows', false, 'windows', 1, 'absolute_reporting', false, 'reporting', 0.05, 'absolute_last', false, 'last', 1);
    batchingStrategy = struct('score_each_item_only_once', NaN, 'absolute_windows', false, 'windows', 0.1, 'absolute_reporting', false, 'reporting', 0.1, 'absolute_last', false, 'last', 1);
    
    %online scenario! 1 at a time!
    %batchingStrategy = struct('score_each_item_only_once', NaN, 'absolute_windows', false, 'windows', 1, 'absolute_reporting', true, 'reporting', 1, 'absolute_last', false, 'last', 1);
    
    results = {};
    legends = {};

    fprintf(1, 'processing dataset %s\n', ds);
    
    for c=1:length(classifiersIcare)
        try
            classifierName = classifiersIcare{c};
            learner = eval(classifierName);
            [budgetAccuracyRecallPrecisionFmeasureTimeFresh budgetAccuracyRecallPrecisionFmeasureTimeInc] = benchmarkClassifier(datasetConfig, learner, batchingStrategy, randSeed, repFactor, freshLearning, incrementalLearning, setRandomWeights);

            if freshLearning
                results{end+1} = budgetAccuracyRecallPrecisionFmeasureTimeFresh;
                legends{end+1} = [classifierName ' (f)'];
            end
            if incrementalLearning
                results{end+1} = budgetAccuracyRecallPrecisionFmeasureTimeInc;
                legends{end+1} = [classifierName ' (inc)'];
            end
        catch err
            fprintf(2, ['failed on classifier ' classifierName ' for dataset ' ds '\n' getReport(err)]);
            %rethrow(err);
        end
    end
    if ~isempty(legends) 
        plotBenchmark(ds, results, legends);
    else
        fprintf(2, ['none of our classifiers could handle dataset ' ds '\n']);
    end
end % dataset

elapsed = toc(overallTime);
fprintf(1,'compareClassifiers elapsed time=%f\n',elapsed);

end


function [budgetAccuracyRecallPrecisionFmeasureTimeFresh budgetAccuracyRecallPrecisionFmeasureTimeInc] = benchmarkClassifier(datasetConfig, learner, batchingStrategy, randSeed, repFactor, freshLearning, incrementalLearning, setRandomWeights)

[algRand, cmRand, baseLineRand] = computeRandSeeds(randSeed);
RandStream.setGlobalStream(algRand);

if ~incrementalLearning && ~freshLearning; error('You should ask at least for one of fresh or incremental learning'); end

for experimentId=1:repFactor
    cm = CrowdManager(datasetConfig.datafile, datasetConfig.primaryKeyCol, datasetConfig.classCol, datasetConfig.crowdUserCols, datasetConfig.crowdLabelCols, datasetConfig.featureCols, datasetConfig.fakeCrowd, datasetConfig.balancedLabels, cmRand, true);

    shuffledIds = shuffle(1:cm.numberOfItems, baseLineRand);
    
    if setRandomWeights
        randomW = randi(100, 1, cm.numberOfItems);
        cm.updateDataWeights(shuffledIds, randomW);
    end

    %what would happen if we were allowed to ask a fixed number of questions, i.e. our budget.
    [budgets, windowSize, reportingStep] = computeBudgets(batchingStrategy, cm.numberOfItems);

    budgetAccuracyRecallPrecisionFmeasureTimeFresh = zeros(0, 6); 
    budgetAccuracyRecallPrecisionFmeasureTimeInc = zeros(0, 6); 
    
    trainRange=[]; testRange=[]; firstTime=true;
    for budgetIdx=1:length(budgets)
        curBudget = budgets(budgetIdx);
        if 2*curBudget > cm.numberOfItems; break; end
        if curBudget==0; continue; end
        
        trainRange = shuffledIds(1:curBudget);
        testRange = shuffledIds(curBudget+1:2*curBudget);
        fprintf(1,'train & test size: %d \n', curBudget);

        if freshLearning
            % doing a fresh training each time!
            ts = tic;
            [predictedLabels, model] = learner.trainPredict(...
                                        cm.getDataWeights(trainRange), ...
                                        cm.getData(trainRange), ...
                                        cm.getRealLabels(trainRange), ...
                                        cm.getData(testRange));
            curTimeFresh = toc(ts);

            [accuracy, recall, precision, f1_measure] = binClassError(predictedLabels, cm.getRealLabels(testRange));
            budgetAccuracyRecallPrecisionFmeasureTimeFresh(budgetIdx, :) = [curBudget accuracy recall precision f1_measure curTimeFresh];
        end
        
        if incrementalLearning
            % doing incremental training each time!
            ts = tic;
            if firstTime
                [predictedLabels, model] = learner.trainPredict(...
                                            cm.getDataWeights(trainRange), ...
                                            cm.getData(trainRange), ...
                                            cm.getRealLabels(trainRange), ...
                                            cm.getData(testRange));
                prevModel = model;
                firstTime = false;
            else
                newWeCanAsk=curBudget-budgets(budgetIdx-1);
                deltaTrainRange = trainRange(end-newWeCanAsk+1:end);
                [predictedLabels, model] = learner.trainIncPredict(...
                                            cm.getDataWeights(deltaTrainRange), ...
                                            cm.getData(deltaTrainRange), ...
                                            cm.getRealLabels(deltaTrainRange), ...
                                            cm.getData(testRange),...
                                            prevModel);
                prevModel = model;
            end
            curTimeFresh = toc(ts);

            [accuracy, recall, precision, f1_measure] = binClassError(predictedLabels, cm.getRealLabels(testRange));
            budgetAccuracyRecallPrecisionFmeasureTimeInc(budgetIdx, :) = [curBudget accuracy recall precision f1_measure curTimeFresh];
        end
        
    end

    if experimentId==1;
        innerSize = size(budgetAccuracyRecallPrecisionFmeasureTimeFresh);
        repBudgetAccuracyRecallPrecisionFmeasureTimeFresh = zeros([repFactor innerSize]); 
        innerSize = size(budgetAccuracyRecallPrecisionFmeasureTimeInc);
        repBudgetAccuracyRecallPrecisionFmeasureTimeInc = zeros([repFactor innerSize]);
    end

    repBudgetAccuracyRecallPrecisionFmeasureTimeFresh(experimentId, :, :) = budgetAccuracyRecallPrecisionFmeasureTimeFresh;
    repBudgetAccuracyRecallPrecisionFmeasureTimeInc(experimentId, :, :) = budgetAccuracyRecallPrecisionFmeasureTimeInc;
    fprintf(1,'end of repetition %d \n', experimentId);
end % This is the end of each repetition!

budgetAccuracyRecallPrecisionFmeasureTimeFresh = removeDimension(nanmean(repBudgetAccuracyRecallPrecisionFmeasureTimeFresh, 1), 1);
budgetAccuracyRecallPrecisionFmeasureTimeInc = removeDimension(nanmean(repBudgetAccuracyRecallPrecisionFmeasureTimeInc, 1), 1);

end

function plotBenchmark(datasetName, results, legends)
assert(length(results) == length(legends) && length(legends)>0);

figure('Color',[1 1 1], 'Name', [ datasetName ' : Different classifiers']);

fontsize = 16;
fontweight = 'bold';
set(0,'defaultaxesfontsize', fontsize);
set(0,'defaultaxesfontweight', fontweight);
set(0,'defaultlinelinewidth',1);

BudgetCol = 1;
AccuracyCol = 2;
RecallCol = 3;
PrecisionCol = 4;
FmeasureCol = 5;
TimeCol = 6;
colors = {'b','r','g', 'm', 'y', 'c', 'k', 'b'};

subplot(1,2,1);

QualityCol = AccuracyCol;
firstLegend = true;
for i=1:length(results)
    budgetAccuracyRecallPrecisionFmeasureTime = results{i};
    X = budgetAccuracyRecallPrecisionFmeasureTime(:,BudgetCol);
    Y = budgetAccuracyRecallPrecisionFmeasureTime(:,QualityCol);
    plot(X, Y, [':*' colors{i}], 'DisplayName', legends{i});
    
    if firstLegend
        hold all;
        legend('-DynamicLegend');
        firstLegend = false;
    end    
end
xlabel('Training (Testing) Size');
ylabel('Quality');
title('Learning Curve');

subplot(1,2,2);

firstLegend = true;
for i=1:length(results)
    budgetAccuracyRecallPrecisionFmeasureTime = results{i};
    X = budgetAccuracyRecallPrecisionFmeasureTime(:,BudgetCol);
    Y = budgetAccuracyRecallPrecisionFmeasureTime(:,TimeCol);
    plot(X, Y, [':*' colors{i}], 'DisplayName', legends{i});
    
    if firstLegend
        hold all;
        legend('-DynamicLegend');
        firstLegend = false;
    end    
end
xlabel('Training (Testing) Size');
ylabel('Running Time');
title('Time Complexity (secs)');



end

function [ output_args ] = studyCeffect(doOneStep, doIterative, doIterativeIID, rankersIcare, datasetsIcare, CRange)
import java.util.*;
overallTime = tic;

if nargin < 5
    datasetsIcare = {};
end
if nargin < 4
    rankersIcare = {};
end
if nargin < 3
    doIterativeIID = false;
end
if nargin < 2
    doIterative = true;
end
if nargin < 1
    doOneStep = true;
    error('Must run with args');
end

init_dataset_configs

datasets = {...
    'cancer', 'iris', 'pima_indians_diabetes', 'transfusion', 'glass', 'mammographic_masses', 'segmentation', 'vehicle',...
    'haberman', 'optdigits', 'spambase', 'vertebral_column', 'ionosphere', 'parkinsons', 'steel_plates_faults', 'yeast', ...
    'entity_small_perfect', 'entity_small_crowd', 'entity_small_qt_crowd', ...
    'entity_perfect', 'entity_crowd', 'entity_qt_crowd', ...
    'cmu_sunglass', ... %'cmu_neutral', 'cmu_happy', 'cmu_sad', 'cmu_angry', 
    'caltech_gender', ...
    'caltech_humanface', ...
    'caltech_lobster', ...
    'tweets_10k', ...
    'tweets_100k' ...
    };


ranker_functions = java.util.Hashtable;
ranker_functions.put('pbr', 'calculateProbBeingRight');
ranker_functions.put('pbr2', 'calculateProbBeingRight2');
%ranker_functions.put('mer', 'calculateModelError');
ranker_functions.put('crd', 'calculateCrowdError');
ranker_functions.put('var', 'calculateVariance');
ranker_functions.put('goodness', 'calculateGoodness');
ranker_functions.put('tgoodness', 'calculateTheirGoodness');
ranker_functions.put('smd', 'calculateMarginDistance');
%ranker_functions.put('combined', 'calculateCombined');
ranker_functions.put('pst', 'calculateProvost');

randSeed = 12345; % -1 means do not change the random seed every time!

nCores = feature('numCores')
if nCores > 2
    if matlabpool('size')~=12
        out = findResource('scheduler', 'type', 'local');
        out.ClusterSize = 12;
        matlabpool(out);
    end
end
%create iterator;
%dsiter = ArrayList(dataset_features.keySet).iterator();
%while dsiter.hasNext()
%    ds=dsiter.next();
for dsiter=1:length(datasets)
    ds = datasets{dsiter};
    if ~isempty(datasetsIcare) && ~ismember(ds, datasetsIcare) continue; end
    config = eval([ds '_conf']);
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
        rankerOpt = struct('nboots', 10, 'alpha', 0.05, 'type', 'norm', 'C', 1);
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
        %learner = @bClassify;
    end
    if isfield(config, 'datafile')
        datafile = config.datafile;
    else
        datafile = [ds '.vis'];
    end
    if isfield(config, 'featureCols');
        featureCols = config.featureCols;
    else
        error(['Unknown feature set for' ds]);
    end
       
    mkdir(ds);
    cd(ds);   
    fprintf(1, 'going to dataset %s\n', ds);    
       
    for CIdx=1:length(CRange)
        currentCvalue = CRange(CIdx);
        rankerOpt.C = currentCvalue;
        
        % running one steps
        if doOneStep
            rankiter = ArrayList(ranker_functions.keySet).iterator();
            while rankiter.hasNext()
                rankerAcr = rankiter.next();
                if ~isempty(rankersIcare) && ~ismember(rankerAcr, rankersIcare) continue; end

                rankerName = ranker_functions.get(rankerAcr);
                rankerFunc = str2func(ranker_functions.get(rankerAcr));
                outFilename = ['1-' rankerAcr '-' num2str(currentCvalue)];

                if strcmp(rankerAcr, 'pst') && ~isequal(learner, @bClassify) && ~isequal(learner, @tClassify)
                    continue;
                end                

                if exist([outFilename '.jpg'], 'file') == 2
                    fprintf(1,'skipping OneStepLearningD with %s\n', rankerName);
                else
                    fprintf(1,'going to run OneStepLearningD with %s\n', rankerName);
                    OneStepLearningD(repFactor, learner, randSeed, datafile, primaryKeyCol, classCol, crowdUserCols, crowdLabelCols, featureCols, fakeCrowd, balancedLabels, initTrain, reso, rankerFunc, rankerOpt, outFilename);
                end
            end
        end
        % running iterative
        if doIterative
            rankiter = ArrayList(ranker_functions.keySet).iterator();
            while rankiter.hasNext()
                rankerAcr = rankiter.next();
                if ~isempty(rankersIcare) && ~ismember(rankerAcr, rankersIcare) continue; end

                rankerName = ranker_functions.get(rankerAcr);
                rankerFunc = str2func(ranker_functions.get(rankerAcr));
                outFilename = ['iter-' rankerAcr '-' num2str(currentCvalue)];

                if strcmp(rankerAcr, 'pst') && ~isequal(learner, @bClassify) && ~isequal(learner, @tClassify)
                    continue;
                end          

                if exist([outFilename '.jpg'], 'file') == 2
                    fprintf(1,'skipping IterativeLearningD with %s\n', rankerName);
                else
                    fprintf(1,'going to run IterativeLearningD with %s\n', rankerName);
                    IterativeLearningD(repFactor, learner, randSeed, datafile, primaryKeyCol, classCol, crowdUserCols, crowdLabelCols, featureCols, fakeCrowd, balancedLabels, initTrain, reso, useWeightedSampling, rankerFunc, rankerOpt, outFilename);
                end
            end
        end
        % running iterative
        if doIterativeIID
            rankiter = ArrayList(ranker_functions.keySet).iterator();
            while rankiter.hasNext()
                rankerAcr = rankiter.next();
                if ~isempty(rankersIcare) && ~ismember(rankerAcr, rankersIcare) continue; end

                rankerName = ranker_functions.get(rankerAcr);
                rankerFunc = str2func(ranker_functions.get(rankerAcr));
                outFilename = ['iid-' rankerAcr '-' num2str(currentCvalue)];

                if strcmp(rankerAcr, 'pst') && ~isequal(learner, @bClassify) && ~isequal(learner, @tClassify)
                    continue;
                end          

                if exist([outFilename '.jpg'], 'file') == 2
                    fprintf(1,'skipping IterativeLearningDiid with %s\n', rankerName);
                else                    
                    fprintf(1,'going to run IterativeLearningDiiD with %s\n', rankerName);
                    IterativeLearningDiid(repFactor, learner, randSeed, datafile, primaryKeyCol, classCol, crowdUserCols, crowdLabelCols, featureCols, fakeCrowd, balancedLabels, initTrain, reso, useWeightedSampling, iidBatchRatio, rankerFunc, rankerOpt, outFilename);
                end
            end
        end        
    end % of the current resolution
    cd('..');
end % dataset

elapsed = toc(overallTime);
fprintf(1,'runUCI elapsed time=%f\n',elapsed);

end




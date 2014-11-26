function [ output_args ] = runUCI(doOneStep, doIterative, doIterativeIID, scorersIcare, datasetsIcare)
import java.util.*;
overallTime = tic;

if nargin < 5
    datasetsIcare = {};
end
if nargin < 4
    scorersIcare = {};
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

randSeed = 12345; % -1 means do not change the random seed every time!

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


active_learners_map = java.util.Hashtable;
active_learners_map.put('pbr', 'calculateProbBeingRight');
active_learners_map.put('pbr2', 'calculateProbBeingRight2');
active_learners_map.put('mer', 'calculateModelError');
active_learners_map.put('crd', 'calculateCrowdError');
active_learners_map.put('var', 'calculateVariance');
active_learners_map.put('goodness', 'calculateGoodness');
active_learners_map.put('tgoodness', 'calculateTheirGoodness');
active_learners_map.put('smd', 'calculateMarginDistance');
%active_learners_map.put('combined', 'calculateCombined');
active_learners_map.put('pst', 'calculateProvost');
active_learners_map.put('iwal2', nan);
active_learners_map.put('adapt', 'calculateAdaptiveSampling');



nCores = feature('numCores')
if nCores > 2
    if matlabpool('size')~=nCores
        defaultProfile = parallel.defaultClusterProfile;
        myCluster = parcluster(defaultProfile);
        matlabpool(myCluster, 'open');
    end
end
%create iterator;
%dsiter = ArrayList(dataset_features.keySet).iterator();
%while dsiter.hasNext()
%    ds=dsiter.next();
for dsiter=1:length(datasets)
    ds = datasets{dsiter};
    if ~isempty(datasetsIcare) && ~ismember(ds, datasetsIcare) continue; end
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
    if ~isfield(datasetConfig, 'learner')
        %datasetConfig.learner = @incSClassify;
        %datasetConfig.learner = @sClassifyFast;
        %datasetConfig.learner = @pegasosClassify;
        %datasetConfig.learner = @nClassify;
        datasetConfig.learner = @tClassify;
        %datasetConfig.learner = @twClassify;
        %datasetConfig.learner = tClassifier;
        %datasetConfig.learner = sClassifier;
        %datasetConfig.learner = bClassifier;
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

    chooserOptions = struct('strategy', NaN);
    
    mkdir(ds);
    cd(ds);   
    fprintf(1, 'going to dataset %s\n', ds);
    try
        % running one steps
        if doOneStep
            scoreiter = ArrayList(active_learners_map.keySet).iterator();
            while scoreiter.hasNext()
                activeLearnerAcr = scoreiter.next();
                if ~isempty(scorersIcare) && ~ismember(activeLearnerAcr, scorersIcare); continue; end

                activeLearner = active_learners_map.get(activeLearnerAcr);
                scorerFunc = str2func(active_learners_map.get(activeLearnerAcr));
                outFilename = ['1-' activeLearnerAcr];
                
                if strcmp(activeLearnerAcr, 'pst') && ~isequal(learner, @bClassify) && ~isequal(learner, @tClassify)
                    continue;
                end                               
                
                if exist([outFilename '.jpg'], 'file') == 2
                    fprintf(1,'skipping OneStepLearningD with %s\n', activeLearner);
                else
                    fprintf(1,'going to run OneStepLearningD with %s\n', activeLearner);
                    OneStepLearningD(repFactor, learner, randSeed, datafile, primaryKeyCol, classCol, crowdUserCols, crowdLabelCols, featureCols, fakeCrowd, balancedLabels, initialTrainRatio, batchingStrategy, scorerFunc, scorerOptions, outFilename);
                end
            end
        end
        % running iterative
        if doIterative
            scoreiter = ArrayList(active_learners_map.keySet).iterator();
            while scoreiter.hasNext()
                activeLearnerAcr = scoreiter.next();
                if ~isempty(scorersIcare) && ~ismember(activeLearnerAcr, scorersIcare); continue; end

                activeLearner = str2func(active_learners_map.get(activeLearnerAcr));
                outFilename = ['iter-' activeLearnerAcr];
                
                if strcmp(activeLearnerAcr, 'pst') && ~isequal(learner, @bClassify) && ~isequal(learner, @tClassify)
                    continue;
                end
                
%                if strcmp(activeLearnerAcr, 'iwal2')
%                    batchingStrategy.score_each_item_only_once = true;
%                    chooserOptions.strategy = 'bernoliWeightedSampling';
%                else
%                    batchingStrategy.score_each_item_only_once = false;
%                    chooserOptions.strategy = 'rescalingWeightedSampling';
%                end                

                
                if exist([outFilename '.jpg'], 'file') == 2
                    fprintf(1,'skipping IterativeLearningD with %s\n', func2str(activeLearner));
                else
                    fprintf(1,'going to run IterativeLearningD with %s\n', func2str(activeLearner));
                    %IterativeLearningD(datasetConfig, scorerFunc, scorerOptions, chooserOptions, batchingStrategy, randSeed, repFactor, outFilename);
                    ActiveLearningFixedBatchOld(datasetConfig, activeLearner, batchingStrategy, randSeed, repFactor, outFilename);
                end
            end
        end      
        cd('..');
    catch err
        cd('..');
        rethrow(err);
    end
end % dataset

elapsed = toc(overallTime);
fprintf(1,'runUCI elapsed time=%f\n',elapsed);

end




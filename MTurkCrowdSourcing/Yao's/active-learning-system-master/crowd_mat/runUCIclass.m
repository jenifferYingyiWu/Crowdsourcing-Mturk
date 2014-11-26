function [ output_args ] = runUCIclass(doOneStep, doIterative, doIterativeIID, scorersIcare, datasetsIcare)
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
    'tweets_10k_crowd', ...
    'tweets_100k' ...
    };

% Iris datasets
% 'iris', 'segmentation', 'haberman', 'ionosphere', 'parkinsons', 'glass', 'vertebral_column', 'cancer', 'mammographic_masses', 'steel_plates_faults', 'transfusion', 'vehicle', 'optdigits', 'pima_indians_diabetes', 'yeast', 'spambase'


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
active_learners_map.put('ent', nan);
active_learners_map.put('entboot', nan);
active_learners_map.put('clus', nan);


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
        %datasetConfig.learner = incSClassifier;
        %datasetConfig.learner = sClassifierFast;
        %datasetConfig.learner = pegasosClassifier;
        %datasetConfig.learner = nClassifier;
        %datasetConfig.learner = tClassifier;
        %datasetConfig.learner = twClassifier;
        %datasetConfig.learner = sClassifier;
        %datasetConfig.learner = bClassifier;
        datasetConfig.learner = rlsClassifier;
    end
    if ~isfield(datasetConfig, 'datafile')
        datasetConfig.datafile = [ds '.vis'];
    end
    if ~isfield(datasetConfig, 'featureCols');
        error(['Unknown feature set for' ds]);
    end

    %typical batching iterative

    batchingStrategy = struct('absolute_whatYouCanSee', false, 'whatYouCanSee', 1, 'absolute_budgetPerStep', false, 'budgetPerStep', 0.1, 'absolute_budgetReportingFrequency', false, 'budgetReportingFrequency', 0.1, 'absolute_totalBudget', false, 'totalBudget', 1);
    
    %online scenario! 1 at a time!

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

                activeLearner = instantiateActiveLearner(activeLearnerAcr, randSeed, datasetConfig.learner);
                outFilename = ['1-' activeLearnerAcr];
                
                if exist([outFilename '.jpg'], 'file') == 2
                    fprintf(1,'skipping OneStepLearningD with %s\n', activeLearner.fullName);
                else
                    fprintf(1,'going to run OneStepLearningD with %s\n', activeLearner.fullName);
                    ActiveLearningUpfront(datasetConfig, activeLearner, batchingStrategy, randSeed, repFactor, outFilename);
                    % OneStepLearningD(repFactor, datasetConfig.learner, randSeed, datafile, primaryKeyCol, classCol, crowdUserCols, crowdLabelCols, featureCols, fakeCrowd, balancedLabels, initialTrainRatio, batchingStrategy, scorerFunc, scorerOptions, outFilename);
                end
            end
        end
        % running iterative
        if doIterative
            scoreiter = ArrayList(active_learners_map.keySet).iterator();
            while scoreiter.hasNext()
                activeLearnerAcr = scoreiter.next();
                if ~isempty(scorersIcare) && ~ismember(activeLearnerAcr, scorersIcare); continue; end

                activeLearner = instantiateActiveLearner(activeLearnerAcr, randSeed, datasetConfig.learner);
                outFilename = ['iter-' activeLearnerAcr];
                
%                if strcmp(activeLearnerAcr, 'iwal2')
%                    batchingStrategy.score_each_item_only_once = true;
%                    chooserOptions.strategy = 'bernoliWeightedSampling';
%                else
%                    batchingStrategy.score_each_item_only_once = false;
%                    chooserOptions.strategy = 'rescalingWeightedSampling';
%                end                

                
                if exist([outFilename '.jpg'], 'file') == 2
                    fprintf(1,'skipping IterativeLearningD with %s\n', activeLearner.fullName);
                else
                    fprintf(1,'going to run IterativeLearningD with %s\n', activeLearner.fullName);
                    ActiveLearningFixedBatch(datasetConfig, activeLearner, batchingStrategy, randSeed, repFactor, outFilename);
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
fprintf(1,'runUCI finished, with an elapsed time=%f\n',elapsed);

end

function al = instantiateActiveLearner(alName, randSeed, classifier)

separate = false;

if strcmp(alName, 'iwal2')
    C0details = struct('C0type', 'linearSVM', 'C0delta', 0.1, 'C0normalized', false, 'nBoots', 10);
    al = ActiveLearningIWAL(nan, classifier, computeRandSeeds(randSeed, separate), 'Rademacher-Bootstrap', C0details);
elseif strcmp(alName, 'var')
    nBoots = 10;
    al = ActiveLearnerUncertainty(classifier, computeRandSeeds(randSeed, separate), nBoots);
elseif strcmp(alName, 'pst')
    nBoots = 10;
    al = ActiveLearnerProvost(classifier, computeRandSeeds(randSeed, separate), nBoots);
elseif strcmp(alName, 'pbr')
    nBoots = 10;
    al = ActiveLearnerProbBeingRight(classifier, computeRandSeeds(randSeed, separate), nBoots);
elseif strcmp(alName, 'entboot')
    nBoots = 10;
    al = ActiveLearnerEntropyBootstrap(classifier, computeRandSeeds(randSeed, separate), nBoots);
elseif strcmp(alName, 'mer')
    nBoots = 10;
    al = ActiveLearnerExpectedModelError(classifier, computeRandSeeds(randSeed, separate), nBoots);
elseif strcmp(alName, 'crd')
    nBoots = 10;
    al = ActiveLearnerExpectedModelAccuracy(classifier, computeRandSeeds(randSeed, separate), nBoots);
elseif strcmp(alName, 'ent')
    al = ActiveLearnerEntropy(classifier, computeRandSeeds(randSeed, separate));
elseif strcmp(alName, 'clus')
    al = ActiveLearnerClustering(10, randSeed, 'fastkmeans');
else    
    error(['Unknown : ' alName]);
end

end




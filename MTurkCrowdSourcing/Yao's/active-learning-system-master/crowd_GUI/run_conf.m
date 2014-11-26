function run_conf(name)
if isa(name,'char')
    if ~exist(name,'file')
        disp('config file doesn''t exist');
        return;
    end
    load(name);
	dss_available = file_conf_info.dss_available;
    alsFull_available = file_conf_info.alsFull_available;
    al_Full_map = file_conf_info.al_Full_map;
    als_available = file_conf_info.als_available;
    dss_Icare = file_conf_info.dss_Icare;
    als_Icare = file_conf_info.als_Icare;
    doOneStep = file_conf_info.doOneStep;
    doIterative = file_conf_info.doIterative;
    doIterativeIID = file_conf_info.doIterativeIID;
    randSeed = file_conf_info.randSeed;
    ds_info_map = file_conf_info.ds_info_map;
    al_info_map = file_conf_info.al_info_map;
    ds_conf_map = file_conf_info.ds_conf_map;
    classifiers = file_conf_info.classifiers;
    
    tmp_Struct = file_conf_info;
    
elseif isa(name,'struct')
    dss_available = name.dss_available;
    alsFull_available = name.alsFull_available;
    al_Full_map = name.al_Full_map;
    als_available = name.als_available;
    dss_Icare = name.dss_Icare;
    als_Icare = name.als_Icare;
    doOneStep = name.doOneStep;
    doIterative = name.doIterative;
    doIterativeIID = name.doIterativeIID;
    randSeed = name.randSeed;
    ds_info_map = name.ds_info_map;
    al_info_map = name.al_info_map;
    ds_conf_map = name.ds_conf_map;
    classifiers = name.classifiers;
    
    tmp_Struct = name;
    
else
    disp('wrong input');
    return;
end

mode = 'notGUI';
tmpObj = findobj('Tag','Run_Button');

if exist('hObject')
   if ~isempty(tmpObj) && ~isempty(hObject) && hObject == tmpObj
       mode = 'GUI';
   end
end

[result,msg] = errorCheck(tmp_Struct);
if strcmp(mode,'notGUI')
    if ~result
        disp(msg);
        return;
    end
else
    hideMessage();
    set(findobj('Tag','Info_Panel'),'Title','Information');
    set(findobj('Tag','Info_Text'),'Visible','off','ForegroundColor','black','String','');
    if ~result
        set(findobj('Tag','Info_Text'),'Visible','on','ForegroundColor','red','String',msg);
        return;
    end
end

nCores = feature('numCores');
if nCores > 2
    if matlabpool('size')~=nCores
        defaultProfile = parallel.defaultClusterProfile;
        myCluster = parcluster(defaultProfile);
        matlabpool(myCluster, 'open');
    end
end
overallTime = tic;

for dsiter=1:length(dss_Icare)
    
    ds = dss_Icare{dsiter};
    datasetConfig = ds_conf_map.(ds);
    ds_info = ds_info_map.(ds);
    repFactor = ds_info.repFactor;
    

    batchingStrategy = struct('absolute_whatYouCanSee', ds_info.absolute_whatYouCanSee, ...
    'whatYouCanSee', ds_info.whatYouCanSee, 'absolute_budgetPerStep', ds_info.absolute_budgetPerStep, 'budgetPerStep',...
    ds_info.budgetPerStep, 'absolute_budgetReportingFrequency', ds_info.absolute_budgetReportingFrequency,...
    'budgetReportingFrequency', ds_info.budgetReportingFrequency,'absolute_totalBudget',ds_info.absolute_totalBudget,...
    'totalBudget', ds_info.totalBudget);



    chooserOptions = struct('strategy', ds_info.strategy);
    mkdir(ds);
    cd(ds);   
    fprintf(1, 'going to dataset %s\n', ds);    
    try
        if doOneStep
            for i=1:length(als_Icare)
                activeLearnerAcr = als_Icare{i};
                activeLearner = getALInstance(activeLearnerAcr,al_Full_map,al_info_map);
                outFilename = ['1-' activeLearnerAcr];
                
                if exist([outFilename '.jpg'], 'file') == 3
                    fprintf(1,'skipping OneStepLearningD with %s\n', activeLearner.fullName);
                else
                    fprintf(1,'going to run OneStepLearningD with %s\n', activeLearner.fullName);
                    
                    if ~isfield(datasetConfig, 'learner')
                        datasetConfig.learner = eval(al_info_map.(activeLearnerAcr).classifier);
                    end
                    
                    ActiveLearningUpfront(datasetConfig, activeLearner, batchingStrategy, randSeed, repFactor, outFilename);
                    % OneStepLearningD(repFactor, datasetConfig.learner, randSeed, datafile, primaryKeyCol, classCol, crowdUserCols, crowdLabelCols, featureCols, fakeCrowd, balancedLabels, initialTrainRatio, batchingStrategy, scorerFunc, scorerOptions, outFilename);
                end
            end
        end
        if doIterative
            for i=1:length(als_Icare)
                activeLearnerAcr = als_Icare{i};
                activeLearner = getALInstance(activeLearnerAcr,al_Full_map,al_info_map);
                outFilename = ['iter-' activeLearnerAcr];
                if exist([outFilename '.jpg'], 'file') == 3
                    fprintf(1,'skipping IterativeLearningD with %s\n', activeLearner.fullName);
                else
                    fprintf(1,'going to run IterativeLearningD with %s\n', activeLearner.fullName);
                    
                    if ~isfield(datasetConfig, 'learner')
                        datasetConfig.learner = eval(al_info_map.(activeLearnerAcr).classifier);
                    end
                    
                    
                    ActiveLearningFixedBatch(datasetConfig, activeLearner, batchingStrategy, randSeed, repFactor, outFilename);
                end
            end
        end
        cd('..');
    catch err
        cd('..');
        rethrow(err);
    end
    elapsed = toc(overallTime);
    fprintf(1,'runUCI elapsed time=%f\n',elapsed);
end

end


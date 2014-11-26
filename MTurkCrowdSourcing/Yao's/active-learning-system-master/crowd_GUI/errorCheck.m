function [result,msg] = errorCheck(name)

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


if isempty(als_Icare)
    msg = 'Please choose at least one active learner!';
    result = false;
    return;
end
if isempty(dss_Icare)
    msg = 'Please choose at least one dataset!';
    result = false;
    return;
end
for i=1:length(dss_Icare)
   ds = dss_Icare{i};
   ds_info = ds_info_map.(ds);
   datasetConfig = ds_conf_map.(ds);
   try
        [~, cmRand, baseLineRand] = computeRandSeeds(randSeed,false);
        cm = CrowdManager(datasetConfig.datafile, datasetConfig.primaryKeyCol, datasetConfig.classCol,...
            datasetConfig.crowdUserCols, datasetConfig.crowdLabelCols, datasetConfig.featureCols,...
            datasetConfig.fakeCrowd, datasetConfig.balancedLabels, cmRand, true, datasetConfig.inputFilePath);
        [~, testRange] = splitRange(cm.numberOfItems, datasetConfig.initialTrainRatio);
        testRange = shuffle(testRange, baseLineRand);
        nTest = length(testRange);
        
        
        if isnan(ds_info.repFactor)
            msg = ['repFactor not set for ' ds];
            result = false;
            return;
        end
        
        
        if ds_info.absolute_whatYouCanSee
            if ~(1 <= ds_info.whatYouCanSee && ds_info.whatYouCanSee <= nTest)
                msg = ['assert(1 <= whatYouCanSee <= nTest) failed for ' ds];
                result = false;
                return;
            end
        else
            if ~(0 < ds_info.whatYouCanSee && ds_info.whatYouCanSee <= 1)
                msg = ['assert(0 < whatYouCanSee <= 1) failed for ' ds];
                result = false;
                return;
            end
        end
        
        
        if ds_info.absolute_budgetPerStep
            if ~(1 <= ds_info.budgetPerStep && ds_info.budgetPerStep <= nTest)
                msg = ['assert(1 <= budgetPerStep <= nTest) failed for ' ds];
                result = false;
                return;
            end
        else
            if ~(0 < ds_info.budgetPerStep && ds_info.budgetPerStep <= 1)
                msg = ['assert(0 < budgetPerStep <= 1) failed for ' ds];
                result = false;
                return;
            end
        end

        if ds_info.absolute_budgetReportingFrequency
            if ~(1 <= ds_info.budgetReportingFrequency && ds_info.budgetReportingFrequency < nTest)
                msg = ['assert(1 <= budgetReportingFrequency < nTest) failed for ' ds];
                result = false;
                return;
            end
        else
            if ~(0 < ds_info.budgetReportingFrequency && ds_info.budgetReportingFrequency < 1)
                msg = ['assert(0 < budgetReportingFrequency < 1) failed for ' ds];
                result = false;
                return;
            end
        end
        
        if ds_info.absolute_totalBudget
            if ~(0 <= ds_info.totalBudget && ds_info.totalBudget < nTest)
                msg = ['assert(0 <= totalBudget < nTest) failed for ' ds];
                result = false;
                return;
            end
        else
            if ~(0 <= ds_info.totalBudget && ds_info.totalBudget <= 1)
                msg = ['assert(0= < totalBudget <= 1) failed for ' ds];
                result = false;
                return;
            end
        end    
        
        if ~(ds_info.budgetPerStep<=ds_info.totalBudget && ds_info.budgetPerStep<=ds_info.whatYouCanSee)
            msg = ['assert(budgetPerStep<=totalBudget && budgetPerStep<=whatYouCanSee) failed for ' ds];
            result = false;
            return;
        end

   catch
       msg = ['error occurs when calculating nTest for ' ds];
       result = false;
       return;
   end
   
end
msg = '';
result = true;

end

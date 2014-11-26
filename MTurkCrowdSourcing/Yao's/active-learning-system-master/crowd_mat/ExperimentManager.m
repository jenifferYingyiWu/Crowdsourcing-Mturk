classdef ExperimentManager < handle
    properties
        datasetConfig = [];
        algorithmInfo = [];
        provenance = [];
        repetitionFactor = []; 
        resultFileName = [];
        activeRandStream = [];
        passiveRandStream = [];
        
        errorUpfrontBaseline = [];
        errorIterativeBaseline = [];
        projectedCV = [];
        projectedTC = [];
        projectedT = [];
        projectedBS = [];
        errorIterativeSmart = [];
        %just to remember the order in which we asked the questions
        whichQuestions = [];
        passiveRunTimes = [];
        activeRunTimes = [];
        
        SUMerrorUpfrontBaseline = [];
        SUMerrorIterativeBaseline = [];
        SUMprojectedCV = [];
        SUMprojectedTC = [];
        SUMprojectedT = [];
        SUMprojectedBS = [];
        SUMerrorIterativeSmart = [];
        SUMwhichQuestions = [];
        SUMpassiveRunTimes = [];
        SUMactiveRunTimes = [];
        
        whenWasAsked = java.util.Hashtable;
        timesWasAsked = java.util.Hashtable;
        
        whoseError = java.util.Hashtable;
        errorMeasure = java.util.Hashtable;
        cMgr = [];
        overallTime = [];
        thisBudgetTime = [];
        lastCompletedExperimentId = [];
    end %properties
    
    methods
        % constructor
        function obj = ExperimentManager(datasetConfig, algorithmInfo, provenance, repetitionFactor, resultFileName, activeRandStream, passiveRandStream)
            obj.datasetConfig = datasetConfig;
            obj.algorithmInfo = algorithmInfo;
            obj.provenance = provenance;
            obj.repetitionFactor = repetitionFactor;
            obj.resultFileName = resultFileName;
            obj.activeRandStream = activeRandStream;
            obj.passiveRandStream = passiveRandStream;

            % the values are the appropriate indices in our matrices
            obj.whoseError.put('CrowdError', 1);
            obj.whoseError.put('ModelError', 2);
            obj.whoseError.put('OverallError', 3);
            
            obj.errorMeasure.put('Accuracy', 2);
            obj.errorMeasure.put('F1measure', 5);            
        end
        
        function initializeForTheFirstTime(obj, crowdManager)
            obj.overallTime = tic;
            obj.thisBudgetTime = tic;
            obj.cMgr = crowdManager;
            obj.lastCompletedExperimentId = 0;
            
            maxNRows = obj.cMgr.numberOfItems;
            % initialize them with -1 to determine the real zero error from un-assigned values.
            obj.errorUpfrontBaseline = ones(maxNRows, 3, 5) * -Inf;
            obj.errorIterativeBaseline = ones(maxNRows, 3, 5) * -Inf;
            obj.projectedCV = ones(maxNRows, 5) * -Inf;
            obj.projectedTC = ones(maxNRows, 5) * -Inf;
            obj.projectedT = ones(maxNRows, 5) * -Inf;
            obj.projectedBS = ones(maxNRows, 5) * -Inf;
            obj.errorIterativeSmart = ones(maxNRows, 3, 5) * -Inf;
            %just to remember the order in which we asked the questions
            obj.whichQuestions = ones(maxNRows, obj.cMgr.getNFeatures()+1) * -Inf;
            obj.passiveRunTimes = ones(maxNRows, 2) * -Inf;
            obj.activeRunTimes = ones(maxNRows, 2) * -Inf;
        end
        
        function crowdLabels = recordPassiveAction(obj, trainIdx, crowdIdx, unlabeledIdx)            
            thisPassiveTime = tic;
            sillyIterativePrediction = [obj.cMgr.getCrowdLabels(crowdIdx); ...
                                        obj.datasetConfig.learner.trainPredict([obj.cMgr.getDataWeights(trainIdx); ones(length(crowdIdx),1)], ...
                                                        obj.cMgr.getData([trainIdx; crowdIdx]), ...
                                                        [obj.cMgr.getRealLabels(trainIdx); obj.cMgr.getCrowdLabels(crowdIdx)], ...
                                                        obj.cMgr.getData(unlabeledIdx)) ...
                           ];
            % measure time
            thisTime = toc(thisPassiveTime);
                       
            sillyUpfrontPrediction = [obj.cMgr.getCrowdLabels(crowdIdx); ... 
                                        obj.datasetConfig.learner.trainPredict(obj.cMgr.getDataWeights(trainIdx), ...
                                                                    obj.cMgr.getData(trainIdx), ...
                                                                    obj.cMgr.getRealLabels(trainIdx), ...
                                                                    obj.cMgr.getData(unlabeledIdx)) ...
                                       ];

                                   
            % find the next empty slot!
            budgetIdx = find(obj.errorIterativeBaseline(:,1,1)==-Inf, 1, 'first');
            %measure the error!
            obj.errorIterativeBaseline(budgetIdx, :,  :) = bin3ClassError(sillyIterativePrediction, obj.cMgr.getRealLabels([crowdIdx; unlabeledIdx]), length(crowdIdx));
            obj.errorUpfrontBaseline(budgetIdx, :, :) = bin3ClassError(sillyUpfrontPrediction, obj.cMgr.getRealLabels([crowdIdx; unlabeledIdx]), length(crowdIdx));
            
            totalWeCanAsk = length(crowdIdx);
            [accuracy, recall, precision, f1_measure] = errEstimateTrainCrowdCrossVal(obj.datasetConfig.learner, obj.cMgr.getDataWeights(trainIdx), obj.cMgr.getData(trainIdx), obj.cMgr.getRealLabels(trainIdx), obj.cMgr.getDataWeights(crowdIdx), obj.cMgr.getData(crowdIdx), obj.cMgr.getCrowdLabels(crowdIdx), obj.cMgr.getData(unlabeledIdx), obj.passiveRandStream);
            obj.projectedCV(budgetIdx, :) = [totalWeCanAsk accuracy recall precision f1_measure];
            [accuracy, recall, precision, f1_measure] = errEstimateTrainCrowdErr(obj.datasetConfig.learner, obj.cMgr.getDataWeights(trainIdx), obj.cMgr.getData(trainIdx), obj.cMgr.getRealLabels(trainIdx), obj.cMgr.getDataWeights(crowdIdx), obj.cMgr.getData(crowdIdx), obj.cMgr.getCrowdLabels(crowdIdx), obj.cMgr.getData(unlabeledIdx));
            obj.projectedTC(budgetIdx, :) = [totalWeCanAsk accuracy recall precision f1_measure];
            [accuracy, recall, precision, f1_measure] = errEstimateTrainErr(obj.datasetConfig.learner, obj.cMgr.getDataWeights(trainIdx), obj.cMgr.getData(trainIdx), obj.cMgr.getRealLabels(trainIdx), obj.cMgr.getDataWeights(crowdIdx), obj.cMgr.getData(crowdIdx), obj.cMgr.getCrowdLabels(crowdIdx), obj.cMgr.getData(unlabeledIdx));
            obj.projectedT(budgetIdx, :) = [totalWeCanAsk accuracy recall precision f1_measure];
            [accuracy, recall, precision, f1_measure] = errEstimateBootstrap(obj.datasetConfig.learner, obj.cMgr.getDataWeights(trainIdx), obj.cMgr.getData(trainIdx), obj.cMgr.getRealLabels(trainIdx), obj.cMgr.getDataWeights(crowdIdx), obj.cMgr.getData(crowdIdx), obj.cMgr.getCrowdLabels(crowdIdx), obj.cMgr.getData(unlabeledIdx), obj.passiveRandStream);
            obj.projectedBS(budgetIdx, :) = [totalWeCanAsk accuracy recall precision f1_measure];    

            obj.passiveRunTimes(budgetIdx, :) = [totalWeCanAsk thisTime];
            oneBudgetValueReached(obj, budgetIdx, totalWeCanAsk);
        end      
        
        function oneBudgetValueReached(obj, budgetIdx, totalQuestionsAsked)
            % save partial results to disk
            experimentId = obj.lastCompletedExperimentId + 1;
            s = struct('errorUpfrontBaseline', obj.errorUpfrontBaseline, 'errorIterativeBaseline', obj.errorIterativeBaseline, ...
                'errorIterativeSmart', obj.errorIterativeSmart, 'experimentId', experimentId, 'passiveRunTimes', obj.passiveRunTimes, 'activeRunTimes', obj.activeRunTimes);
            
            save(obj.resultFileName, '-struct', 's');            
        end

        function crowdLabels = recordActiveAction(obj, trainIdx, crowdIdx, unlabeledIdx, newlyAskedToCrowd, activeLearningTime)
            assert(isempty(setdiff(newlyAskedToCrowd, crowdIdx))); % because the crowdIdx is supposed to already contain newlyAskedToCrowd
            assert(isempty(intersect(unlabeledIdx, newlyAskedToCrowd))); % because the unlabeledIdx is supposed to not have newlyAskedToCrowd
            
            
            % find the next empty slot!
            nextQuesIdx = find(obj.whichQuestions(:,1)==-Inf, 1, 'first');
            for qid=1:length(newlyAskedToCrowd)
                itemIdx=newlyAskedToCrowd(qid);
                obj.whichQuestions(nextQuesIdx,:) = [obj.cMgr.getData(itemIdx) obj.cMgr.getRealLabels(itemIdx)];
                pk = obj.cMgr.getPrimaryKeys(itemIdx);
                if obj.whenWasAsked.containsKey(pk)
                    obj.whenWasAsked.put(pk, obj.whenWasAsked.get(pk)+nextQuesIdx);
                else
                    obj.whenWasAsked.put(pk, nextQuesIdx)
                end
                if obj.timesWasAsked.containsKey(pk)
                    obj.timesWasAsked.put(pk, obj.timesWasAsked.get(pk)+1);
                else
                    obj.timesWasAsked.put(pk, 1)
                end
                nextQuesIdx = nextQuesIdx + 1;
            end

            useCrowd = true;
            useOneWeightsForCrowd = false;
            
            if useCrowd
                if useOneWeightsForCrowd
                    WC = ones(length(crowdIdx),1);
                else
                    WC = obj.cMgr.getDataWeights(crowdIdx);
                end
                W = [obj.cMgr.getDataWeights(trainIdx); WC];
                D = obj.cMgr.getData([trainIdx; crowdIdx]);
                L = [obj.cMgr.getRealLabels(trainIdx); obj.cMgr.getCrowdLabels(crowdIdx)];
            else
                W = obj.cMgr.getDataWeights(trainIdx);
                D = obj.cMgr.getData([trainIdx]);
                L = [obj.cMgr.getRealLabels(trainIdx)];
            end
            
            
            thisActiveTime = tic;
            smartPrediction = [obj.cMgr.getCrowdLabels(crowdIdx); obj.datasetConfig.learner.trainPredict(W, D, L, obj.cMgr.getData(unlabeledIdx))];
            thisTime = toc(thisActiveTime) + activeLearningTime;
                           
            % find the next empty slot!
            budgetIdx = find(obj.errorIterativeSmart(:,1,1)==-Inf, 1, 'first');
            totalQuestionsAsked = length(crowdIdx);
            obj.activeRunTimes(budgetIdx, :) = [totalQuestionsAsked thisTime];
            
            obj.errorIterativeSmart(budgetIdx, :, :) = bin3ClassError(smartPrediction, ...
                                                                  [obj.cMgr.getRealLabels(crowdIdx); obj.cMgr.getRealLabels(unlabeledIdx)], ... 
                                                              length(crowdIdx));
                                                          
        end
        
        function [avgImprovement, relAvgImprovement] = finalSaveToFile(obj, whoseErrorToShow, whatErrorMeasureToShow)
            % first sum up the last iteration of the experiment
            obj.lastCompletedExperimentId = obj.lastCompletedExperimentId+1;
            rollupLastExperiment(obj, obj.lastCompletedExperimentId);
            
            whatWeShow = obj.whoseError.get(whoseErrorToShow);
            measureIdx = obj.errorMeasure.get(whatErrorMeasureToShow);
            assert(~isempty(whatWeShow) && ~isempty(measureIdx));
            
            obj.errorUpfrontBaseline= removeDimension(nanmean(obj.SUMerrorUpfrontBaseline,1), 1);
            obj.errorIterativeBaseline = removeDimension(nanmean(obj.SUMerrorIterativeBaseline,1), 1);
            obj.errorIterativeSmart = removeDimension(nanmean(obj.SUMerrorIterativeSmart,1), 1);
            % we are going to only remember the questions asked during the first iteration, because avergae questions makes no sense!
            obj.whichQuestions = removeDimension(obj.SUMwhichQuestions(1,:,:), 1);
            obj.passiveRunTimes = removeDimension(nanmean(obj.SUMpassiveRunTimes,1), 1);
            obj.activeRunTimes = removeDimension(nanmean(obj.SUMactiveRunTimes,1), 1);
            allPKs = obj.whenWasAsked.keySet.toArray;
            whenWasAskedAvg = zeros(length(allPKs), 2);
            for i=1:length(allPKs)
                pk = allPKs(i);
                whenWasAskedAvg(i,:) = [pk obj.whenWasAsked.get(pk)/obj.timesWasAsked.get(pk)];
            end

            runningTime = toc(obj.overallTime);
            fprintf(1,'elapsed time=%f\n', runningTime);

%            datasetConfig, algorithmInfo, provenance, repetitionFactor, resultFileName
            s = obj.datasetConfig;
            save(obj.resultFileName, '-struct', 's');
            s = obj.algorithmInfo;
            save(obj.resultFileName, '-struct', 's', '-append');
            s = obj.provenance;
            save(obj.resultFileName, '-struct', 's', '-append');
            s = struct('repetitionFactor', obj.repetitionFactor);
            save(obj.resultFileName, '-struct', 's', 'repetitionFactor', '-append');
            
            % to assure the size is small enough!
            if size(obj.whichQuestions,2) > 10000
                obj.whichQuestions = [];
            end
            
            s = struct(obj);
            save(obj.resultFileName, '-struct', 's', 'errorUpfrontBaseline', 'errorIterativeBaseline', 'projectedCV', 'projectedTC', 'projectedT', 'projectedBS' , 'errorIterativeSmart', 'whichQuestions', 'passiveRunTimes', 'activeRunTimes', '-append');
            numberOfUsedThreads = matlabpool('size');
            save(obj.resultFileName, 'whenWasAskedAvg', 'numberOfUsedThreads', '-append'); 
            
            fh = figure('Name', [obj.datasetConfig.datafile ' : ' obj.algorithmInfo.activeLearner.fullName],'Color',[1 1 1]);
            set(0,'defaultaxesfontsize',20);
            set(0,'defaultlinelinewidth',3);

            plot(obj.errorUpfrontBaseline(:, whatWeShow, 1), obj.errorUpfrontBaseline(:,whatWeShow, measureIdx), 'b*:', 'DisplayName', 'UpfrontBaseline');
            hold all;
            legend('-DynamicLegend');
            plot(obj.errorIterativeBaseline(:, whatWeShow, 1), obj.errorIterativeBaseline(:, whatWeShow, measureIdx), 'ro:', 'DisplayName', 'IterativeBaseline');
            plot(obj.errorIterativeSmart(:, whatWeShow, 1), obj.errorIterativeSmart(:, whatWeShow, measureIdx), 'g+:', 'DisplayName', strcat('IterativeSmart(', obj.algorithmInfo.activeLearner.fullName,')'));

            budgetStep = obj.errorIterativeSmart(2, whatWeShow, 1) - obj.errorIterativeSmart(1, whatWeShow, 1);
            xlabel(strcat('Total # of questions, asked  ',num2str(budgetStep), ' at a time'));
            ylabel('Accuracy: ratio of correctly-classified.');
            avgImprovement = nanmean(obj.errorIterativeSmart(:, whatWeShow, measureIdx) - obj.errorIterativeBaseline(:, whatWeShow, measureIdx));
            relAvgImprovement = nanmean(obj.errorIterativeSmart(:, whatWeShow, measureIdx) - obj.errorIterativeBaseline(:, whatWeShow, measureIdx)) / nanmean(obj.errorIterativeBaseline(:, whatWeShow, measureIdx));
            title(['improve: abs= ' num2str(avgImprovement) ', rel= ' num2str(relAvgImprovement)]);
            hgsave(fh, strcat(obj.resultFileName,'.fig'));
            print(fh,'-djpeg', strcat(obj.resultFileName,'.jpg'));
            print(fh,'-deps', strcat(obj.resultFileName,'.eps'));
        end
        

        
        function resetForNewIteration(obj, crowdManager)
            if isempty(obj.lastCompletedExperimentId)
                initializeForTheFirstTime(obj, crowdManager);
            else
                obj.lastCompletedExperimentId = obj.lastCompletedExperimentId + 1;
            end
            
            if obj.lastCompletedExperimentId >= 1
                rollupLastExperiment(obj, obj.lastCompletedExperimentId);
            end
        end
           
        function rollupLastExperiment(obj, lastCompletedExperimentId)
            % removing the -Inf space holders
            obj.errorUpfrontBaseline = obj.errorUpfrontBaseline(obj.errorUpfrontBaseline(:,1,1)~=-Inf,:,:);
            obj.errorIterativeBaseline = obj.errorIterativeBaseline(obj.errorIterativeBaseline(:,1,1)~=-Inf,:,:);
            obj.projectedCV = obj.projectedCV(obj.projectedCV(:,1)~=Inf,:);
            obj.projectedTC = obj.projectedTC(obj.projectedTC(:,1)~=Inf,:);
            obj.projectedT = obj.projectedT(obj.projectedT(:,1)~=Inf,:);
            obj.projectedBS = obj.projectedBS(obj.projectedBS(:,1)~=Inf,:);
            obj.errorIterativeSmart = obj.errorIterativeSmart(obj.errorIterativeSmart(:,1,1)~=-Inf,:,:);
            obj.whichQuestions = obj.whichQuestions(obj.whichQuestions(:,1)~=-Inf,:);
            
            
            if obj.lastCompletedExperimentId==1 % this means we just finished the iteration 1 and so we are ready to collect sums!
                obj.SUMerrorUpfrontBaseline = zeros([obj.repetitionFactor size(obj.errorUpfrontBaseline)]);
                obj.SUMerrorIterativeBaseline = zeros([obj.repetitionFactor size(obj.errorIterativeBaseline)]);
                obj.SUMprojectedCV = zeros([obj.repetitionFactor size(obj.projectedCV)]);
                obj.SUMprojectedTC = zeros([obj.repetitionFactor size(obj.projectedTC)]);
                obj.SUMprojectedT = zeros([obj.repetitionFactor size(obj.projectedT)]);
                obj.SUMprojectedBS = zeros([obj.repetitionFactor size(obj.projectedBS)]);
                obj.SUMerrorIterativeSmart = zeros([obj.repetitionFactor size(obj.errorIterativeSmart)]);
                obj.SUMwhichQuestions = zeros([obj.repetitionFactor size(obj.whichQuestions)]);
                obj.SUMpassiveRunTimes = zeros([obj.repetitionFactor size(obj.passiveRunTimes)]);
                obj.SUMactiveRunTimes = zeros([obj.repetitionFactor size(obj.activeRunTimes)]);
            end

            % adding current iteration to the sum
            obj.SUMerrorUpfrontBaseline(lastCompletedExperimentId,:,:,:) = obj.errorUpfrontBaseline;
            obj.SUMerrorIterativeBaseline(lastCompletedExperimentId,:,:,:) = obj.errorIterativeBaseline;
            obj.SUMprojectedCV(lastCompletedExperimentId, :, :) = obj.projectedCV;
            obj.SUMprojectedTC(lastCompletedExperimentId, :, :) = obj.projectedTC;
            obj.SUMprojectedT(lastCompletedExperimentId, :, :) = obj.projectedT;
            obj.SUMprojectedBS(lastCompletedExperimentId, :, :) = obj.projectedBS;
            obj.SUMerrorIterativeSmart(lastCompletedExperimentId,:,:,:) = obj.errorIterativeSmart;
            obj.SUMwhichQuestions(lastCompletedExperimentId,:,:) =  obj.whichQuestions;
            obj.SUMpassiveRunTimes(lastCompletedExperimentId,:,:) = obj.passiveRunTimes;
            obj.SUMactiveRunTimes(lastCompletedExperimentId,:,:) = obj.activeRunTimes;

            % re-initialize them with -Inf to determine the real zero error from un-assigned values.
            maxNRows = obj.cMgr.numberOfItems;
            obj.errorUpfrontBaseline = ones(maxNRows, 3, 5) * -Inf;
            obj.errorIterativeBaseline = ones(maxNRows, 3, 5) * -Inf;
            obj.projectedCV = ones(maxNRows, 5) * -Inf;
            obj.projectedTC = ones(maxNRows, 5) * -Inf;
            obj.projectedT = ones(maxNRows, 5) * -Inf;
            obj.projectedBS = ones(maxNRows, 5) * -Inf;
            obj.errorIterativeSmart = ones(maxNRows, 3, 5) * -Inf;
            obj.passiveRunTimes = ones(maxNRows, 2) * -Inf;
            obj.activeRunTimes = ones(maxNRows, 2) * -Inf;
            obj.whichQuestions(:, :) = -Inf;                        
        end
    end %methods
    
end %classdef




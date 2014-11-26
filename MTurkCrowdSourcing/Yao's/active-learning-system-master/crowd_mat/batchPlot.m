function batchPlot(oneOrIterRange, camera_ready, justLegends)
%close all;

OneStepIterative = {'Upfront', 'Iterative'};
symbs = {'*-', '+:'};

if nargin==0
    oneOrIterRange = 1+1:length(OneStepIterative);
end
if nargin==2 && camera_ready
    camera_ready=true;
else
    camera_ready=false;
end
if nargin<3
    justLegends = false;
end

errorTypes = {'budget', 'Accuracy', 'Recall', 'Precision', 'F1-measure'};
LearnerTypes = {'Crowd', 'Model', 'Overall'};

[pathstr, curDir, ext] = fileparts(pwd);
scrsz = get(0,'ScreenSize');

fontsize = 16;
fontweight = 'bold';
set(0,'defaultaxesfontsize', fontsize);
set(0,'defaultaxesfontweight', fontweight);
set(0,'defaultlinelinewidth',2);

dim1=3;
dim2=4;

firstLegend = true;

fullNames = java.util.Hashtable;
fullNames.put('pbr', 'ProbBeingRight');
fullNames.put('mer', 'MinExpError');
fullNames.put('crd', 'MinCrowdError');
fullNames.put('var', 'Uncertainty');
fullNames.put('goodness', 'Explorer');
fullNames.put('smd', 'MarginDistance');
fullNames.put('combined', 'Combined');
fullNames.put('pst', 'BootstrapLV');
fullNames.put('pbr2', 'MinExpError');


methods = {'var', 'pbr2'}; %, 'smd', 'pst', 'pbr', 'crd', 'tgoodness', 'goodness'}; %, 'mer', 'combined'};

colors = {'g', 'm', 'y', 'c', 'k'};

auc = [];
auclog = [];
maxVerImprov = [];
avgVerImprov = [];
maxHorzImprov = [];
avgHorzImprov = [];

oldIdx = nan;

learnerIdx = 2;
errIdx=5;

    legs = {};
    nextM = 1;
    figure('Color',[1 1 1], 'Name', [errorTypes{errIdx}]);
    
    batchSizeRange = 1:10:201;
    for osi=oneOrIterRange
        needBaseline = true;
        for m=1:length(methods)
            if osi==1
                filename = ['1-' methods{m} '-' num2str(batchSizeRange(1))];
            else
                filename = ['iter-' methods{m} '-' num2str(batchSizeRange(1))];
            end
            if exist([filename '.mat'], 'file')~=2
                continue;
            end
            
            processingTimes = [];            
            for nextM=1:length(batchSizeRange)
                batchSize = batchSizeRange(nextM);
                if osi==1
                    filename = ['1-' methods{m} '-' num2str(batchSize)];
                else
                    filename = ['iter-' methods{m} '-' num2str(batchSize)];
                end
                if exist([filename '.mat'], 'file')~=2
                    error(['missing batch size ' num2str(batchSize)]);
                end
                C = load(filename);
                if osi==1; idx = find(C.errorUpfrontSmart(:,learnerIdx,1)>-1, 1, 'last');
                else idx = find(C.errorIterativeSmart(:,learnerIdx,1)>-1, 1, 'last'); end

                if needBaseline
%                    needBaseline = false;
                    if osi==1
                        x = C.errorUpfrontBaseline(1:idx,learnerIdx,1);
                        y = C.errorUpfrontBaseline(1:idx,learnerIdx,errIdx);
                    else
                        x = C.errorIterativeBaseline(1:idx,learnerIdx,1);
                        y = C.errorIterativeBaseline(1:idx,learnerIdx,errIdx);
                    end
                    xibase = x; yibase = y;
                end
                if firstLegend || camera_ready || justLegends
                    hold all;
                    legend('-DynamicLegend');
                    firstLegend = false;
                end
                if osi==1
                    x = C.errorUpfrontSmart(1:idx,learnerIdx,1);
                    y = C.errorUpfrontSmart(1:idx,learnerIdx,errIdx);
                else
                    x = C.errorIterativeSmart(1:idx,learnerIdx,1);
                    y = C.errorIterativeSmart(1:idx,learnerIdx,errIdx);
                end
                processingTimes(nextM) = C.runningTime;
                
                auc(nextM) = areaUnderCurve(x,y);% / (max(x)-min(x));
                xx=x; xx(xx==0)=1; auclog(nextM) = areaUnderCurve(log2(xx),y);% / (max(x)-min(x));
                vd = verticalDistance(xibase, yibase, x, y);
                vertDist = infdiv(y, yibase);
                avgVerImprov(nextM) = nanmean(vertDist);
                hd = horizontalDistance(x, y, xibase, yibase);
                horzDist = infdiv(xibase, xibase-hd);
                if (nanmean(vertDist))<1/3 % if we make things worse, saving questions makes no sense!
                   horzDist(:) = nan;
                end
                avgHorzImprov(nextM) = nanmean(horzDist);
            end % batch size
            whatWeWant = 'avgHorzImprov';
            whatWeWant = 'processingTimes';
            measure = eval(whatWeWant);
            
            plot(batchSizeRange, measure, [colors{m} symbs{osi}], 'DisplayName', [OneStepIterative{osi} fullNames.get(methods{m})]);

            legs{end+1} = [OneStepIterative{osi} fullNames.get(methods{m})];
        end % method
    end % osi
    xlabel('Batch Size ');
    ylabel('Avg. F1-measure'); 
%    title(['blah']);
%    set(gca,'YScale','log');
    xlim([0 205]);

    legend(legs);





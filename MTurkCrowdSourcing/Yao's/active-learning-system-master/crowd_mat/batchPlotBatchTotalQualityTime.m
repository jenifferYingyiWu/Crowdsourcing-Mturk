function batchPlotBatchTotalQualityTime(xIdx, yIdx, curveIdx, interConnectIdx, curveVals, interConnectVals, roundUp, batchSizeRange, methods, camera_ready, justLegends)
%close all;

OneStepIterative = {'Upfront', 'Iterative'};
symbs = {'*-', '+:'};

assert(all(sort(unique([xIdx yIdx curveIdx interConnectIdx]))==[1 2 3 4]), 'incorrect params!');

oneOrIterRange = 2;


if nargin==10 && camera_ready
    camera_ready=true;
else
    camera_ready=false;
end
if nargin<11
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


%methods = {'pbr2'}; % {'var'} ; %, 'pbr2'}; %, 'smd', 'pst', 'pbr', 'crd', 'tgoodness', 'goodness'}; %, 'mer', 'combined'};

colors = {'g', 'm', 'y', 'c', 'k', 'g', 'm', 'y', 'c', 'k', 'g', 'm', 'y', 'c', 'k', 'g', 'm', 'y', 'c', 'k'};

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
     currentDirectory = pwd;
    [upperPath, currentDirectory, ~] = fileparts(currentDirectory);
    figure('Color',[1 1 1], 'Name', [currentDirectory errorTypes{errIdx}]);
    
    for osi=oneOrIterRange
        allBatchTotalQualityTime = zeros(0,4); % each row will contain a 
        needBaseline = true;
        for m=1:length(methods)
            if osi==1
                filename = ['1-' methods{m} '-' num2str(batchSizeRange(1))]
            else
                filename = ['iter-' methods{m} '-' num2str(batchSizeRange(1))]
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
                z = C.detailedRunTimes(:,2);
                if any(C.detailedRunTimes(:,1)~=x)
                    error('The batch-sizes are not consistent!');
                end
                thisBatchTotalQualityTime = [repmat(batchSize, size(x,1), 1) x y z];
                allBatchTotalQualityTime = [allBatchTotalQualityTime; thisBatchTotalQualityTime];
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
            
            %plot(batchSizeRange, measure, [colors{m} symbs{osi}], 'DisplayName', [OneStepIterative{osi} fullNames.get(methods{m})]);

            %legs{end+1} = [OneStepIterative{osi} fullNames.get(methods{m})];            
        end % method
        
        measureNames = {'Batch size', 'Budget (# of questions)', errorTypes{errIdx}, 'Time (sec)'};

        
%        curveUnq = sort(unique(allBatchTotalQualityTime(:,curveIdx)));
%        curveVals = curveUnq(1:length(curveUnq)/howManyCurves:length(curveUnq));
%        curveVals = curveUnq(randi(length(curveUnq), 1, howManyCurves));
        %curveVals = [40 60 100 120];
        howManyCurves = length(curveVals);
        
        %interConnectVals = allBatchTotalQualityTime(:, interConnectIdx);
        %interConnectVals = interConnectVals(randi(length(interConnectVals), 1, howManyInterConnects));
        %interConnectVals = [0 1 2 3 4];
        howManyInterConnects = length(interConnectVals);

        
        interConnectCoordinates = zeros(howManyInterConnects, howManyCurves, 2);
        

        
        legs = {};
        for c=1:length(curveVals)
            roundedData = allBatchTotalQualityTime;
            if roundUp
                % quality up to 2 fractions
                roundedData(:,3) = round(roundedData(:,3)*100)/100;
                % time up to 1 seconds!
                roundedData(:,4) = round(roundedData(:,4));        
            end
            
           subDataIdx = find(roundedData(:,curveIdx)==curveVals(c));
           subData = roundedData(subDataIdx, :);
        
        
           xCol = subData(:,xIdx);
           yCol = subData(:,yIdx);
           plot(xCol, yCol, [colors{c} symbs{osi}]);
           %, 'DisplayName', [OneStepIterative{osi} fullNames.get(methods{m}) ' ' measureNames{curveIdx} '=' num2str(curveVals(c))]);
           legs{end+1} = [OneStepIterative{osi} fullNames.get(methods{m}) ', ' measureNames{curveIdx} '=' num2str(curveVals(c))];
           iCol = subData(:,interConnectIdx);
           for v=1:length(interConnectVals)
              closestIdx = find(iCol==interConnectVals(v),1, 'first');
              if ~isempty(closestIdx)
                  interConnectCoordinates(v, c, :) = [xCol(closestIdx) yCol(closestIdx)];
              else
                  interConnectCoordinates(v, c, :) = [nan nan];
              end
           end
        end
        
        %now draw the dotted lines!
        for v=1:length(interConnectVals)
            for c=1:length(curveVals)-1;
                xxx = [interConnectCoordinates(v,c,1) interConnectCoordinates(v,c+1,1)];
                yyy = [interConnectCoordinates(v,c,2) interConnectCoordinates(v,c+1,2)];
                plot(xxx, yyy, 'r-');
            end
            %xxx = interConnectCoordinates(v,:,1);
            %yyy = interConnectCoordinates(v,:,2);
            %plot(xxx, spline(xxx,yyy,xxx), 'r-');
            text(interConnectCoordinates(v,length(curveVals),1), interConnectCoordinates(v,length(curveVals),2), num2str(interConnectVals(v)));
        end
        xlabel(measureNames{xIdx});
        ylabel(measureNames{yIdx}); 
        %title(['blah']);
        %set(gca,'YScale','log');
        %set(gca,'XScale','log');
        
        xlim([0 max(batchSizeRange)]);

        legend(legs);

    end % osi


function combinePlots3(oneOrIterRange, camera_ready, justLegends)
%close all;

OneStepIterative = {'Upfront', 'Iterative'};
symbs = {'*-', '+:'};

if nargin==0
    oneOrIterRange = 1:length(OneStepIterative);
end
if nargin==2 && camera_ready
    camera_ready=true;
else
    camera_ready=false;
end
if nargin<3
    justLegends = false;
end

ColorSet = [
	0.00  0.00  1.00
	0.00  0.50  0.00
	1.00  0.00  0.00
	0.00  0.75  0.75
	0.75  0.00  0.75
	0.75  0.75  0.00
	0.25  0.25  0.25
	0.75  0.25  0.25
	0.95  0.95  0.00
	0.25  0.25  0.75
	0.75  0.75  0.75
	0.00  1.00  0.00
	0.76  0.57  0.17
	0.54  0.63  0.22
	0.34  0.57  0.92
	1.00  0.10  0.60
	0.88  0.75  0.73
	0.10  0.49  0.47
	0.66  0.34  0.65
	0.99  0.41  0.23
];

ColorSet = [
  1 1 0
  1 0 1
  0 1 1
  1 0 0
  0 1 0
  0 0 1
  1 1 1
];

%set(gca, 'ColorOrder', ColorSet);

errorTypes = {'budget', 'Accuracy', 'Recall', 'Precision', 'F1-measure'};
LearnerTypes = {'Crowd', 'Model', 'Overall'};

[pathstr, curDir, ext] = fileparts(pwd);
scrsz = get(0,'ScreenSize');

fh = figure('Color',[1 1 1], 'Position',[1 scrsz(4) scrsz(3) scrsz(4)], 'Name', curDir);

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
fullNames.put('iwal2', 'IWAL');
fullNames.put('adapt', 'CVHull');
fullNames.put('ent', 'Entropy');
fullNames.put('entboot', 'EntropyBootstrap');


methods = {'smd', 'pst', 'var', 'iwal2', 'adapt', 'ent', 'mer', 'crd'}; %, 'pbr', 'crd', 'tgoodness', 'goodness'}; %, 'mer', 'combined'};
methods = {'ent', 'entboot', 'var', 'crd'}; %, 'pbr', 'crd', 'tgoodness', 'goodness'}; %, 'mer', 'combined'};

colors = {'b','r','g', 'm', 'y', 'c', 'r', 'b'};

auc = [];
auclog = [];
maxVerImprov = [];
avgVerImprov = [];
maxHorzImprov = [];
avgHorzImprov = [];

oldIdx = nan;

for learnerIdx=1:length(LearnerTypes)
for errIdx=2:3:length(errorTypes)
    legs = {};
    nextM = 1;
    %subplot(dim1,dim2, (learnerIdx-1)*4+(errIdx-1),'FontSize', fontsize);
    if ~camera_ready
        subplot(2, 3, (learnerIdx)+(errIdx-2),'FontSize', fontsize, 'FontWeight', fontweight);
    else
        figure('Color',[1 1 1], 'Name', [LearnerTypes{learnerIdx} '-' errorTypes{errIdx}]);
    end
    title([LearnerTypes{learnerIdx} '-' errorTypes{errIdx}]);
        
    for osi=oneOrIterRange
        needBaseline = true;
        for m=1:length(methods)
            if osi==1
                filename = ['1-' methods{m}];
            else
                filename = ['iter-' methods{m}];
            end
            if exist([filename '.mat'], 'file')~=2
                continue;
            end
            C = load(filename);
            if osi==1; idx = find(C.errorUpfrontSmart(:,learnerIdx,1)>-1, 1, 'last');
            else idx = find(C.errorIterativeSmart(:,learnerIdx,1)>-1, 1, 'last'); end
            
            %idx = round(idx/3);
            
            eidx = idx;
            %idx = 319;  %tweet-inc
            %idx = 97; %82; %gender-crowd-inc
            %idx = 18; %tweets100k-perfect
            %idx = 10; %vision50
            %idx = 11; %vision55
            %idx = 133; %face4-sunglass-perfect
            %idx = 6; % entity1d-weighted
            
            if (~isnan(oldIdx) && idx~=oldIdx) || eidx<idx
                error(['Your files do not have the same size. New filename:' filename ' old=' num2str(oldIdx) ' new=' num2str(idx) ' existing=' num2str(eidx)]);
            else
                oldIdx = idx;
            end            
            if needBaseline
                needBaseline = false;
                if osi==1
                    x = C.errorUpfrontBaseline(1:idx,learnerIdx,1);
                    y = C.errorUpfrontBaseline(1:idx,learnerIdx,errIdx);
                else
                    x = C.errorIterativeBaseline(1:idx,learnerIdx,1);
                    y = C.errorIterativeBaseline(1:idx,learnerIdx,errIdx);
                end
                xibase = x; yibase = y;
                plot(x, y, ['k' symbs{osi}], 'DisplayName', [OneStepIterative{osi} 'Baseline']);
                legs{end+1} = [OneStepIterative{osi} 'Baseline'];
                
                errorPredictionExperiment = 0;
                if errorPredictionExperiment==1
                    if learnerIdx==2
                        figure('Color',[1 1 1]);
                        projectedCV = C.projectedCV(1:idx, errIdx);
                        projectedTC = C.projectedTC(1:idx, errIdx);
                        projectedT = C.projectedT(1:idx, errIdx);
                        %projectedBS = C.projectedBS(1:idx, errIdx);
                        plot(x, [yibase projectedCV projectedTC projectedT], [symbs{osi}], 'DisplayName', 'Projected');
                        legend('Actual', 'Projected (Cross-validation)', 'Projected (Train+Crowd err)', 'Projected (Train err)');%, 'Projected (Bootstrap)');
                        xlabel('Total # of questions asked ');
                        ylabel(errorTypes{errIdx});
                        keyboard;
                    end
                end
                
                auc(learnerIdx, errIdx, nextM) = areaUnderCurve(x,y);% / (max(x)-min(x));
                xx=x; xx(xx==0)=1; auclog(learnerIdx, errIdx, nextM) = areaUnderCurve(log2(xx),y);% / (max(x)-min(x));
                vd = verticalDistance(xibase, yibase, x, y);
                vertDist = infdiv(y, yibase);
                avgVerImprov(learnerIdx, errIdx, nextM) = nanmean(vertDist);
                maxVerImprov(learnerIdx, errIdx, nextM) = nanmax(vertDist);
                hd = horizontalDistance(x, y, xibase, yibase);
                horzDist = infdiv(xibase, xibase-hd);
                if (nanmean(vertDist))<1 % if we make things worse, saving questions makes no sense!
                   horzDist(:) = nan;
                end
                avgHorzImprov(learnerIdx, errIdx, nextM) = nanmean(horzDist);
                maxHorzImprov(learnerIdx, errIdx, nextM) = nanmax(horzDist);

                nextM = nextM +1;
                hold all;
            end
            if firstLegend || camera_ready || justLegends
                hold all;
                legend('-DynamicLegend');
                firstLegend = false;
            end
            title([LearnerTypes{learnerIdx} '-' errorTypes{errIdx}]);
            if osi==1
                x = C.errorUpfrontSmart(1:idx,learnerIdx,1);
                y = C.errorUpfrontSmart(1:idx,learnerIdx,errIdx);
            else
                x = C.errorIterativeSmart(1:idx,learnerIdx,1);
                y = C.errorIterativeSmart(1:idx,learnerIdx,errIdx);
            end
            
            plot(x, y, [colors{m} symbs{osi}], 'DisplayName', [OneStepIterative{osi} fullNames.get(methods{m})]);
            legs{end+1} = [OneStepIterative{osi} fullNames.get(methods{m})];
            auc(learnerIdx, errIdx, nextM) = areaUnderCurve(x,y);% / (max(x)-min(x));
            xx=x; xx(xx==0)=1; auclog(learnerIdx, errIdx, nextM) = areaUnderCurve(log2(xx),y);% / (max(x)-min(x));
            vd = verticalDistance(xibase, yibase, x, y);
            vertDist = infdiv(y, yibase);
            avgVerImprov(learnerIdx, errIdx, nextM) = nanmean(vertDist);
            maxVerImprov(learnerIdx, errIdx, nextM) = nanmax(vertDist);
            hd = horizontalDistance(x, y, xibase, yibase);
            horzDist = infdiv(xibase, xibase-hd);
            if (nanmean(vertDist))<1/3 % if we make things worse, saving questions makes no sense!
               horzDist(:) = nan;
            end
            avgHorzImprov(learnerIdx, errIdx, nextM) = nanmean(horzDist);
            maxHorzImprov(learnerIdx, errIdx, nextM) = nanmax(horzDist);

            nextM = nextM +1;
        end
    end % osi
    xlabel('Total # of questions asked ');
    ylabel(errorTypes{errIdx});

    hgsave(fh, ['overall-' LearnerTypes{learnerIdx} '-' errorTypes{errIdx} '.fig']);
    print(fh,'-djpeg', ['overall-' LearnerTypes{learnerIdx} '-' errorTypes{errIdx} '.jpg']);
%close(fh);

end % error type
end % learner type

figure('Color',[1 1 1], 'Name', [curDir ' ratio (measure in AL / measure in passive learning)']);

fontsize = 24;
set(0,'defaultaxesfontsize', fontsize);
set(0,'defaultaxesfontweight', fontweight);
set(0,'defaultlinelinewidth',1);

dim1=1;
dim2=2;

firstLegend = true;

baseLineIdx = 1;

%summaryFile = '~/crowd/results/summary.xls';
%summaryFile = '~/crowd/results/summary-nbc.xls';
%summaryFile = '~/crowd/results/summary-1abs.xls';
%summaryFile = '~/crowd/results/summary-max.xls';
summaryFile = '~/crowd/salat/summary-paper.xls';

if exist(summaryFile, 'file')==2
    header = false;
else
    header = true;
end

%header = true;
sf = fopen(summaryFile, 'a');

%measures = {'AUCLOG', 'AUC', 'MAXHD', 'AVGHD', 'MAXVD', 'AVGVD'};
measures = {'AUCLOG', 'AVGHD', 'AVGVD'};
%measures = {'AUCLOG', 'MAXHD', 'MAXVD'};

if header
    fprintf(sf, 'datasetName,');
    for learnerIdx=1+1:length(LearnerTypes)-1
        for errIdx=2+3:3:length(errorTypes)
            for m=1:length(measures)
                for l=1:length(legs)
                    fprintf(sf, '%s', [LearnerTypes{learnerIdx} '-' errorTypes{errIdx} '-' measures{m} '-' legs{l}]);
                    if learnerIdx==length(LearnerTypes)-1 && errIdx==length(errorTypes) && m==length(measures) && l==length(legs)
                        fprintf(sf, '\n');
                    else
                        fprintf(sf, ',');
                    end
                end
            end
        end
    end
end

dirName = pwd;
[pathstr, datasetName, ext] = fileparts(dirName);
fprintf(sf, '%s,', datasetName);

for learnerIdx=1+1:length(LearnerTypes)-1
for errIdx=2+3:3:length(errorTypes)
    subplot(2, 3, (learnerIdx)+(errIdx-2),'FontSize', fontsize);
    
    AUCLOG = reshape(auclog(learnerIdx, errIdx, :), max(size(auclog(learnerIdx, errIdx, :))), 1);
    AUC = reshape(auc(learnerIdx, errIdx, :), max(size(auc(learnerIdx, errIdx, :))), 1);
    MAXHD = reshape(maxHorzImprov(learnerIdx, errIdx, :), max(size(maxHorzImprov(learnerIdx, errIdx, :))), 1);
    AVGHD = reshape(avgHorzImprov(learnerIdx, errIdx, :), max(size(avgHorzImprov(learnerIdx, errIdx, :))), 1);
    MAXVD = reshape(maxVerImprov(learnerIdx, errIdx, :), max(size(maxVerImprov(learnerIdx, errIdx, :))), 1);
    AVGVD = reshape(avgVerImprov(learnerIdx, errIdx, :), max(size(avgVerImprov(learnerIdx, errIdx, :))), 1);
    
    AUCLOG = relativeImproveOverMin(AUCLOG, baseLineIdx);
    AUC = relativeImproveOverMin(AUC, baseLineIdx);

    for m=1:length(measures)
        data = eval(measures{m});
        for l=1:length(legs)
            fprintf(sf, '%s', num2str(data(l)));
            if learnerIdx==length(LearnerTypes)-1 && errIdx==length(errorTypes) && m==length(measures) && l==length(legs)
                fprintf(sf, '\n');
            else
                fprintf(sf, ',');
            end
        end
    end
    
    bar([AUCLOG ... % AUC MAXHD 
        AVGHD ... %MAXVD
        AVGVD]);

    %bar([AUCLOG ... % AUC 
    %    MAXHD ... 
    %    MAXVD]);
    
    h = gca;
    set(h,'XTickLabel', legs);
    rotateticklabel(h, 90);
    if firstLegend
        %legend('LOGAUC', 'AUC', 'MaxHD', 'AvgHD', 'MaxVD', 'AvgVD');
        legend('LOGAUC', 'AvgHD', 'AvgVD');
        firstLegend = false;
    end

    xlim([0 length(auclog(learnerIdx, errIdx, :))+1]);
    title([LearnerTypes{learnerIdx} '-' errorTypes{errIdx}]);

end % error type
end % learner type


fclose(sf);




choice = 2;
entity1d_scale = 1;
tweet_scale = 2;

numberOfCores = [1 2 4 8 16 32 64]'; 

if choice == entity1d_scale
    UpfrontMarginDistance = [5.576615 5.602595 5.585002 5.593641 5.610342 5.633227 5.658229]';
    UpfrontProbBeingRight = [4.298103 4.348757 4.349025 4.371753 4.459290 4.681001 5.085303]';
    UpfrontMinExpError = [4.923155 4.555859 4.328126 4.240398 4.330252 4.764443 5.306209]';
    UpfrontUncertainty = [3.990429 4.032795 3.996074 4.001177 4.089943 4.373645 4.918069]';
    UpfrontExplorer = [5.437548 4.713795 4.321131 4.127397 4.138993 4.483987 4.800087]';
    IterativeMarginDistance = [5.341828 5.353662 5.334335 5.328374 5.346134 5.380908 5.347584]';
    IterativeProbBeingRight = [5.526828 5.593997 5.600334 5.658396 5.786837 6.846883 8.129386]';
    IterativeMinExpError = [8.065579 6.947923 6.232380 6.096408 6.268827 8.014798 10.644457]';
    IterativeUncertainty = [5.606053 5.615288 5.574452 5.624245 5.780458 6.539485 7.958846]';
    IterativeExplorer = [10.087284 7.760628 6.618721 6.005843 6.002440 6.776195 8.312847]';
elseif choice == tweet_scale
    UpfrontMarginDistance = [13.613640 13.774567 13.731062 13.603656 13.697239 13.733240 13.671908]';
    UpfrontProbBeingRight = [41.093775 29.187375 24.836337 22.294543 22.076773 23.041415 24.574449]';
    UpfrontMinExpError = [nan 11486.818882 5901.079592 3006.051319 1510.837964 770.761835 400.989791]';
    UpfrontUncertainty = [39.573665 26.465655 21.659687 18.992310 18.448046 19.344024 21.014045]';
    UpfrontExplorer = [nan nan nan 5955.390359 2992.119108 1493.247817 757.220198]';    
else 
    error ('Invalid choice');
end


logscale = true;

%%
fh = figure('Color',[1 1 1], 'Name', 'Scale-up Experiment');

fontsize = 16;
fontweight = 'bold';
set(0,'defaultaxesfontsize', fontsize);
set(0,'defaultaxesfontweight', fontweight);
set(0,'defaultlinelinewidth',2);

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

UpfrontStepIterative = {'Upfront', 'Iterative'};
symbs = {'*-', '+:'};

methods = {'smd', 'pst', 'var', 'pbr2', 'goodness'}; %, 'pbr', 'crd', 'tgoodness', 'goodness'}; %, 'mer', 'combined'};

colors = {'b','r','g', 'm', 'y', 'c', 'k'};


for osi=1:2
    for m=1:length(methods)    
        x = numberOfCores;
        if logscale
            x = log2(x);
        end
        
        varName = [UpfrontStepIterative{osi} fullNames.get(methods{m})];
        if exist(varName)==1
            y = eval(varName);
        else
            continue;
        end
        plot(x, y, [colors{m} symbs{osi}], 'DisplayName', varName);

        if firstLegend
            hold all;
            legend('-DynamicLegend');
            firstLegend = false;
        end
    end
    clear eval(varName)
end

grid on;
h = gca;
set(h, 'XTick', x);
set(h,'XTickLabel', num2str(numberOfCores));
set(h,'YScale','log');
xlabel('# of Cores');
ylabel('Time (sec)');
title('Processing times for Twitter dataset')
%legend('MarginDistance', 'MinExpError', 'Uncertainty', 'Explorer');
%legend('IterativeMarginDistance', 'IterativeProbBeingRight', 'IterativeCrowdError', 'IterativeUncertainty', 'IterExplorer');

clear UpfrontMarginDistance  UpfrontProbBeingRight UpfrontMinExpError UpfrontUncertainty UpfrontExplorer IterativeMarginDistance IterativeProbBeingRight 
clear IterativeMinExpError IterativeUncertainty IterativeExplorer 

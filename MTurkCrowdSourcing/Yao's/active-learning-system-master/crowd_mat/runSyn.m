
fontsize = 20;
set(0,'defaultaxesfontsize', fontsize);
set(0,'defaultlinelinewidth',3);


clusterSize = 20;
nClusters = 8;
dim = 1;
meanDist = 5;
%generate_adversarial_data('test', 1, clusterSize, nClusters, dim, meanDist);
%cm = CrowdManager('test', 1, 2, [], 3:(3+dim-1), true, 0);

randSeed = 12345678;
reso = 1;
learner = @tClassify;
repFactor = 1;
nboots=10;
datafile='test123';

primaryKeyCol = 1;
classCol = 2;
crowdCols = [];
featureCols = 3:(3+dim-1);
fakeCrowd = true;

initTrain = 1/nClusters;


matlabpool close force;
%matlabpool open;

res = [];
msg = {};
methods = {};

fprintf(1,'going to run IterativeLearning with calculateProbBeingRight\n');
[res(end+1) msg{end+1}] = IterativeLearningD(repFactor, learner, randSeed, datafile, primaryKeyCol, classCol, crowdCols, featureCols, fakeCrowd, initTrain, reso, @calculateProbBeingRight, struct('nboots', nboots, 'alpha', 0.05, 'type', 'norm'), 'iter-pbr')
methods{end+1} = 'pbr';

fprintf(1,'going to run IterativeLearning with calculateModelError\n');
[res(end+1) msg{end+1}] = IterativeLearningD(repFactor, learner, randSeed, datafile, primaryKeyCol, classCol, crowdCols, featureCols, fakeCrowd, initTrain, reso, @calculateModelError, struct('nboots', nboots, 'alpha', 0.05, 'type', 'norm'), 'iter-mer')
methods{end+1} = 'mer';

fprintf(1,'going to run IterativeLearning with calculateVariance\n');
[res(end+1) msg{end+1}] = IterativeLearningD(repFactor, learner, randSeed, datafile, primaryKeyCol, classCol, crowdCols, featureCols, fakeCrowd, initTrain, reso, @calculateVariance, struct('nboots', nboots, 'alpha', 0.05, 'type', 'norm'), 'iter-var')
methods{end+1} = 'var';

fprintf(1,'going to run IterativeLearning with calculateGoodness\n');
[res(end+1) msg{end+1}] = IterativeLearningD(repFactor, learner, randSeed, datafile, primaryKeyCol, classCol, crowdCols, featureCols, fakeCrowd, initTrain, reso, @calculateGoodness, [], 'iter-goodness');
methods{end+1} = 'goodness';

%fprintf(1,'going to run IterativeLearning with calculateCombined\n');
%[res(end+1) msg{end+1}] = IterativeLearningD(repFactor, learner, randSeed, datafile, primaryKeyCol, classCol, crowdCols, featureCols, fakeCrowd, initTrain, reso, @calculateCombined, struct('nboots', nboots, 'alpha', 0.05, 'type', 'norm', 'w1', 0.5, 'w2', 0.5), 'iter-combined')

fullNames = java.util.Hashtable;
fullNames.put('pbr', 'ProbBeingRight');
fullNames.put('mer', 'MinExpError');
fullNames.put('var', 'Variance');
fullNames.put('goodness', 'Explorer');


figure;
for i=1:length(methods)
    subplot(1,length(methods),i);
    ok = load(['iter-' methods{i}]);
    pp = ok.whichQuestions;
    x = (1:size(pp,1))';
    L = pp(:,2);
    ind1 = find(L==1);
    ind0 = find(L==0);
    c0 = pp(ind0, 1);
    c1 = pp(ind1, 1);
    plot(ind0, c0, 'r.');
    hold on;
    plot(ind1, c1, 'b.');
    title([methods{i} '=' num2str(round(100*res(i))) '%:' msg{i} ]);
end

methods = {'goodness', 'mer', 'pbr', 'var'};
res = {1, 1, 1, 1};

colors = {'b:*','r:*','g:*', 'm:*'}

fh = figure('Color',[1 1 1]);
whatToShow = 2; % modelError
for i=1:length(methods)
    ok = load(['iter-' methods{i}]);
    if i==1
        plot(ok.errorIterativeBaseline(:,whatToShow,1), ok.errorIterativeBaseline(:,whatToShow,2), 'k-', 'DisplayName', 'Baseline');
        hold all;
        legend('-DynamicLegend');
    end
    plot(ok.errorIterativeSmart(:,whatToShow,1), ok.errorIterativeSmart(:,whatToShow,2), colors{i}, 'DisplayName', fullNames.get(methods{i}));
end
xlabel('Total # of questions asked ');
ylabel('Model Accuracy');
title('Model Accuracy');

fh = figure('Color',[1 1 1]);
whatToShow = 3; % overall Error
for i=1:length(methods)
    ok = load(['iter-' methods{i}]);
    if i==1
        plot(ok.errorIterativeBaseline(:,whatToShow,1), ok.errorIterativeBaseline(:,whatToShow,2), 'k-', 'DisplayName', 'Baseline');
        hold all;
        legend('-DynamicLegend');
    end
    plot(ok.errorIterativeSmart(:,whatToShow,1), ok.errorIterativeSmart(:,whatToShow,2), colors{i}, 'DisplayName', fullNames.get(methods{i}));
end
title('Overall Accuracy');
xlabel('Total # of questions asked ');
ylabel('Overall Accuracy');





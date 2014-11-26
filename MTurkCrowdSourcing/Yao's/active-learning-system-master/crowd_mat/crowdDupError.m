randSeed = 123456789;

nboots=1;
fakeCrowd = false;
balancedLabels = false;

if 1==0
    datafile='face4.vis';
    primaryKeyCol = 1;
    isStraight =2; isLeft=3; isRight=4; isUp=5; isOpen=6; isSunglasses=7; isNeutral=8; isHappy=9; isSad=10; isAngry=11;
    classCol = isAngry;
    crowdUserCols = 2:5:46;
    
    %crowdLabelCols = 3:5:46; %	isNeutral
    %crowdLabelCols = 4:5:46; % isHappy
    %crowdLabelCols = 5:5:46; % isSad
    crowdLabelCols = 6:5:46; % isAngry
    
    featureCols = 11+[1:(3+15360)];
else
    datafile='small-entity2.dat';
    primaryKeyCol = 1;
    classCol = 2;
    crowdUserCols = 3:2:8;
    crowdLabelCols = 4:2:8;
    featureCols = 9:12;
end

maxDup = length(crowdLabelCols);
avgAccuracy = zeros(maxDup, nboots);

for r=1:nboots
    cm = CrowdManager(datafile, primaryKeyCol, classCol, crowdUserCols, crowdLabelCols, featureCols, fakeCrowd, balancedLabels);
    range = 1:cm.numberOfItems;
    real = cm.getRealLabels(range);
    for rep = 1:maxDup
        answer = cm.getCrowdLabels(range, rep);
        avgAccuracy(rep, r) = binClassError(answer, real);        
    end
end

avgAccuracySm = mean(avgAccuracy,2);

plot((1:maxDup)', avgAccuracySm);
xlabel('# Questions per HIT');
ylabel('Avg Accuracy');

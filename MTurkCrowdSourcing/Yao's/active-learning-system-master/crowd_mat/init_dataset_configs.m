%defaults: 
%primaryKeyCol = 1;
%classCol = 2;
%crowdUserCols = [];
%crowdLabelCols = [];
%fakeCrowd = true;



%UCI datasets
cancer_conf = struct('featureCols', 2+[1:9]);
glass_conf = struct('featureCols', 2+[1:9]);
haberman_conf = struct('featureCols', 2+[1:3]);
ionosphere_conf = struct('featureCols', 2+[1:34]);
iris_conf = struct('featureCols', 2+[1:4]);
mammographic_masses_conf = struct('featureCols', 2+[1:5]);
optdigits_conf = struct('featureCols', 2+[1:64]);
parkinsons_conf = struct('featureCols', 2+[1:22]);
pima_indians_diabetes_conf = struct('datafile', 'pima-indians-diabetes.vis', 'featureCols', 2+[1:8]);
segmentation_conf = struct('featureCols', 2+[1:19]);
spambase_conf = struct('featureCols', 2+[1:57]);
steel_plates_faults_conf = struct('featureCols', 2+[1:27]);
transfusion_conf = struct('featureCols', 2+[1:4]);
vehicle_conf = struct('featureCols', 2+[1:18]);
vertebral_column_conf = struct('featureCols', 2+[1:6]);
yeast_conf = struct('featureCols', 2+[1:8]);

%ENTITY RESOLUTION
entity_small_perfect_conf = struct('datafile', 'small-entity2.dat', 'featureCols', 9:12);
entity_small_crowd_conf = struct('datafile', 'small-entity2.dat', 'crowdUserCols', 3:2:8, 'crowdLabelCols', 4:2:8, 'featureCols', 9:12, 'fakeCrowd', false);
entity_small_qt_crowd_conf = struct('datafile', 'small-entity2-qt.dat', 'crowdUserCols', 3:2:8, 'crowdLabelCols', 4:2:8, 'featureCols', 9:12, 'fakeCrowd', false);

entity_perfect_conf = struct('datafile', 'entity2.dat', 'featureCols', 9:12);
entity_crowd_conf = struct('datafile', 'entity2.dat', 'crowdUserCols', 3:2:8, 'crowdLabelCols', 4:2:8, 'featureCols', 9:12, 'fakeCrowd', false);
entity_qt_crowd_conf = struct('datafile', 'entity2-qt.dat', 'crowdUserCols', 3:2:8, 'crowdLabelCols', 4:2:8, 'featureCols', 9:12, 'fakeCrowd', false);


%CMU Face dataset
isStraight =2; isLeft=3; isRight=4; isUp=5; isOpen=6; isSunglasses=7; isNeutral=8; isHappy=9; isSad=10; isAngry=11;

cmu_sunglass_conf = struct('initialTrainRatio', 0.11, 'learner', @vrClassify, 'datafile', 'face4.vis', 'classCol', isSunglasses, 'featureCols',  11+[1:(3+15360)]);
cmu_neutral_conf = struct('initialTrainRatio', 0.11, 'learner', @vrClassify, 'datafile', 'face4.vis', 'classCol', isNeutral, 'crowdUserCols', 2:5:46, 'crowdLabelCols', 3:5:46, 'fakeCrowd', false, 'featureCols', 11+[1:(3+15360)]);
cmu_happy_conf = struct('initialTrainRatio', 0.11, 'learner', @vrClassify, 'datafile', 'face4.vis', 'classCol', isHappy, 'crowdUserCols', 2:5:46, 'crowdLabelCols', 4:5:46, 'fakeCrowd', false, 'featureCols', 11+[1:(3+15360)]);
cmu_sad_conf = struct('initialTrainRatio', 0.11, 'learner', @vrClassify, 'datafile', 'face4.vis', 'classCol', isSad, 'crowdUserCols', 2:5:46, 'crowdLabelCols', 5:5:46, 'fakeCrowd', false, 'featureCols', 11+[1:(3+15360)]);
cmu_angry_conf = struct('initialTrainRatio', 0.11, 'learner', @vrClassify, 'datafile', 'face4.vis', 'classCol', isAngry, 'crowdUserCols', 2:5:46, 'crowdLabelCols', 6:5:46, 'fakeCrowd', false, 'featureCols', 11+[1:(3+15360)]);

%Caltech gender dataset
caltech_gender_conf = struct('initialTrainRatio', 0.11, 'learner', @vrClassify, 'datafile', 'gender-small.vis', 'crowdUserCols', 2:3:14, 'crowdLabelCols', 4:3:16, 'fakeCrowd', false, 'featureCols', 2+[1:(3+13348)]);

%Caltech humanface/clutter dataset
caltech_humanface_conf = struct('initialTrainRatio', 0.11, 'learner', @vrClassify, 'datafile', 'vision50.vis', 'featureCols', 2+[1:(3+980640)]);

%Caltech lobster/crayfish dataset
caltech_lobster_conf = struct('initialTrainRatio', 0.11, 'learner', @vrClassify, 'datafile', 'vision-lobster-crayfish-55.vis', 'featureCols', 2+[1:(3+270000)]);

%Tweets 10K dataset
% reso = 1000 
tweets_10k_conf = struct('repFactor', 3, 'initialTrainRatio', 0.1, 'datafile', 'tweets10k.vis', 'crowdUserCols', 2:3:14, 'crowdLabelCols', 4:3:16, 'fakeCrowd', true, 'featureCols', 2+[1:1976]);
tweets_10k_crowd_conf = struct('repFactor', 1, 'initialTrainRatio', 0.1, 'datafile', 'tweets10k.vis', 'crowdUserCols', 2:3:14, 'crowdLabelCols', 4:3:16, 'fakeCrowd', false, 'featureCols', 2+[1:1976]);

%Tweets 100K dataset
tweets_100k_conf = struct('repFactor', 3, 'initialTrainRatio', 0.03, 'datafile', 'tweets100k.vis', 'featureCols', 2+[1:9398]);

dss_available_conf = {...
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


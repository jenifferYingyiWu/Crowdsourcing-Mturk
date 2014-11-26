classdef vrClassifier < Classifier
    properties (Constant)
    end
    
    properties (Hidden)
        % TODO: Barzan needs to use the following features!
        % lambda = 1 / (conf.svm.C *  length(trainIdx)) ;
        % 'MaxNumIterations', 50/lambda
        
        %incSClassifier(solverType, costC, bias, terminationTolerance, lossTolerance) 
        svmSolver = incSClassifier(2, 10, 1, 0.0000001, 0.001); 
    end
    
    methods
        function internalModel = i_train(obj, TrainingData, TrainLabel, Options)

            %this is the raw vision classifier
            overallTime = tic;

            conf.numWords = 600 ;
            conf.numSpatialX = [2 4] ;
            conf.numSpatialY = [2 4] ;
            conf.quantizer = 'kdtree' ;
            conf.svm.C = 10 ;
            conf.svm.solver = 'pegasos' ;
            conf.svm.biasMultiplier = 1 ;
            conf.phowOpts = {'Step', 3} ;
            conf.clobber = false ;
            conf.tinyProblem = false;
            conf.prefix = 'baseline' ;

            if conf.tinyProblem
              conf.prefix = 'tiny' ;
              conf.numClasses = 5 ;
              conf.numSpatialX = 2 ;
              conf.numSpatialY = 2 ;
              conf.numWords = 300 ;
              conf.phowOpts = {'Sizes', 7, 'Step', 5} ;
            end

            % --------------------------------------------------------------------
            %                                                           Setup data
            % --------------------------------------------------------------------
            classes = 0:1;
            trainIdx = 1:size(TrainingData,1);

            internalModel.classes = classes ;
            internalModel.phowOpts = conf.phowOpts ;
            internalModel.numSpatialX = conf.numSpatialX ;
            internalModel.numSpatialY = conf.numSpatialY ;
            internalModel.quantizer = conf.quantizer ;
            internalModel.vocab = [] ;
            internalModel.w = [] ;
            internalModel.b = [] ;
%            internalModel.classify = @classify ;

            % --------------------------------------------------------------------
            %                                                     Train vocabulary
            % --------------------------------------------------------------------
              % Get some PHOW descriptors to train the dictionary
              vocTime = tic;

              selTrainFeats = vl_colsubset(trainIdx, 30) ;

              %for ii = 1:length(selTrainFeats)
              parfor ii = 1:length(selTrainFeats)
                imgIdx = selTrainFeats(ii);
                im = vrClassifier.toImage(TrainingData(imgIdx,:));
                im = single(im);
                [drop, descrs{ii}] = vl_phow(im, internalModel.phowOpts{:}) ;
              end      
              descrs = vl_colsubset(cat(2, descrs{:}), 10e4) ;
              descrs = single(descrs) ;

              % Quantize the descriptors to get the visual words
              vocab = vl_kmeans(descrs, conf.numWords, 'algorithm', 'elkan') ;
              %fprintf(1,'kmeans time=%f\n', toc(vocTime));

            internalModel.vocab = vocab ;

            if strcmp(internalModel.quantizer, 'kdtree')
              internalModel.kdtree = vl_kdtreebuild(vocab) ;
            end

            % --------------------------------------------------------------------
            %                                           Compute spatial histograms
            % --------------------------------------------------------------------

              allIm = TrainingData;
              hists{size(allIm,1)} = [];
              %parfor 
              parfor ii = 1:size(allIm, 1)
                im = vrClassifier.toImage(allIm(ii,:));
                hists{ii} = vrClassifier.getImageDescriptor(internalModel, im);
              end

              hists = cat(2, hists{:}) ;

            % --------------------------------------------------------------------
            %                                                  Compute feature map
            % --------------------------------------------------------------------

            psix = vl_homkermap(hists, 1, 'kchi2', 'gamma', .5) ;
            % --------------------------------------------------------------------
            %                                                            Train SVM
            % --------------------------------------------------------------------
            % TODO: Barzan needs to use the following features!
            % lambda = 1 / (conf.svm.C *  length(trainIdx)) ;
            % 'MaxNumIterations', 50/lambda
            X=psix';
            X=double(X);
            internalModel.internalSolverModel = obj.svmSolver.train(ones(size(TrainLabel)), X, TrainLabel);
        end
        
        function TestLabels = i_predict(obj, internalModel, TestData, Options)
            % --------------------------------------------------------------------
            %                                           Compute spatial histograms
            % --------------------------------------------------------------------

              allIm = TestData;
              hists{size(allIm,1)} = [];
              %parfor 
              parfor ii = 1:size(allIm, 1)
                im = vrClassifier.toImage(allIm(ii,:));
                hists{ii} = vrClassifier.getImageDescriptor(internalModel, im);
              end

              hists = cat(2, hists{:}) ;

            % --------------------------------------------------------------------
            %                                                  Compute feature map
            % --------------------------------------------------------------------

            psix = vl_homkermap(hists, 1, 'kchi2', 'gamma', .5) ;
            
            % --------------------------------------------------------------------
            %                                                Test SVM and evaluate
            % --------------------------------------------------------------------

            % Estimate the class of the test images
            X = psix';
            X = double(X);
            TestLabels = obj.svmSolver.predict(internalModel.internalSolverModel, X);
        end
    end
    
    methods (Static, Hidden)
        function im = standarizeImage(im)
            im = im2single(im) ;
            if size(im,1) > 480, im = imresize(im, [480 NaN]) ; end
        end
        
        function hist = getImageDescriptor(model, im)
            width = size(im,2) ;
            height = size(im,1) ;
            numWords = size(model.vocab, 2) ;

            % get PHOW features
            im = single(im);
            [frames, descrs] = vl_phow(im, model.phowOpts{:}) ;

            % quantize appearance
            switch model.quantizer
              case 'vq'
                [drop, binsa] = min(vl_alldist(model.vocab, single(descrs)), [], 1) ;
              case 'kdtree'
                binsa = double(vl_kdtreequery(model.kdtree, model.vocab, ...
                                              single(descrs), ...
                                              'MaxComparisons', 15)) ;
            end

            for i = 1:length(model.numSpatialX)
              binsx = vl_binsearch(linspace(1,width,model.numSpatialX(i)+1), frames(1,:)) ;
              binsy = vl_binsearch(linspace(1,height,model.numSpatialY(i)+1), frames(2,:)) ;

              % combined quantization
              bins = sub2ind([model.numSpatialY(i), model.numSpatialX(i), numWords], ...
                             binsy,binsx,binsa) ;
              hist = zeros(model.numSpatialY(i) * model.numSpatialX(i) * numWords, 1) ;
              hist = vl_binsum(hist, ones(size(bins)), bins) ;
              hists{i} = single(hist / sum(hist)) ;
            end
            hist = cat(1,hists{:}) ;
            hist = hist / sum(hist) ;

        end
        
        function [className, score] = classify(model, im)
            hist = vrClassifier.getImageDescriptor(model, im) ;
            psix = vl_homkermap(hist, 1, .7, 'kchi2') ;
            scores = model.w' * psix + model.b' ;
            [score, best] = max(scores) ;
            className = model.classes{best} ;
        end
        
        function [im] = toImage(row)
            dims = round(row(1:3));
            im = reshape(row(4:3+prod(dims)), dims(1), dims(2), dims(3));
        end
    end
    
end


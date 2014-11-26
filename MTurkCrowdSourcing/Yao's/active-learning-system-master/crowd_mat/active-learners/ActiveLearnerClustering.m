classdef ActiveLearnerClustering < ActiveLearnerSubsetSampling    
    % Implements the entropy-based algorithm in "Active Learning Literature
    % Survey" by Burr Settles, page 15. Scores are the entropy between the
    % class probabilities produced by the probabilistic classifier.
    properties (Constant)
        scoresEachItemOnlyOnce = false;
        requiredClassifierTypes = {};
    end

    properties
        acronym = 'clus';
        fullName = 'Clustering';
        K = 10;
        kmeans_algorithm = 'fastkmeans';
    end

    methods
        function obj = ActiveLearnerClustering(K, randStream, kmeans_algorithm)
            obj = obj@ActiveLearnerSubsetSampling(nan, nan, randStream, true, true, true);
            obj.K = K;
            obj.kmeans_algorithm = kmeans_algorithm;
            if strcmp(kmeans_algorithm, 'fastkmeans') || strcmp(kmeans_algorithm, 'external_kmeans')
                obj.removePathWithKeywords('vlfeat')
            elseif strcmp(kmeans_algorithm, 'vl_feat')
                obj.removePathWithKeywords('crowd_mat/external')
            elseif strcmp(kmeans_algorithm, 'builtin')
                obj.removePathWithKeywords('vlfeat')
                obj.removePathWithKeywords('crowd_mat/external')                
            else
                error('unsupported algorithm');
            end
        end
            
        function removePathWithKeywords(obj, strToSearchFor)
            curPath = path;
            curPath = strsplit(curPath, ':');
            for i=1:length(curPath)
                dir = curPath{i};
                if ~isempty(strfind(dir, strToSearchFor))
                    rmpath(dir);
                end
            end
            fprintf(1, 'Removed all the directories containing %s!\n', strToSearchFor);            
        end
        
        function clusteringScores = calculateScores(obj, trainWeights, trainData, trainLabel, testData)
            bsTime=tic;

            nTest = size(testData,1);
            if obj.K>nTest
                obj.K = nTest;
            end
            clusteringScores = zeros(nTest, 1);

            %recursiveAddToPath('~/umich-research/active-learning-system/crowd_mat/external/');            
            %ok1 = tic; 
            if strcmp(obj.kmeans_algorithm, 'fastkmeans')
                [centers,mincenter, D ,q2,quality] = kmeans(testData, obj.K);
            end;
            %t1=toc(ok1);
            %fprintf(1,'fastkmeans time=%f\n', t1);

            %ok2 = tic; 
            if strcmp(obj.kmeans_algorithm, 'external_kmeans')
                [IDX, C, D] = k_means(testData, obj.K); 
            end
            %t2=toc(ok2);
            %fprintf(1,'k_means time=%f\n', t2);

            %recursiveRemovePath('~/umich-research/active-learning-system/crowd_mat/external/');
            
            %MATLAB
            if strcmp(obj.kmeans_algorithm, 'builtin')
                [IDX,C,sumd,D] = kmeans(testData, obj.K);
            end
            
            %recursiveAddToPath('~/umich-research/active-learning-system/vlfeat-0.9.17/'); 
            %ok4=tic;
            if strcmp(obj.kmeans_algorithm, 'vl_feat')
                [Dtranspose, IDX] = vl_kmeans(testData', 10, 'Algorithm', 'ANN');
                D = Dtranspose';
            end
            %t4=toc(ok4);
            %fprintf(1,'fastkmeans, k_means, MATLAB time, vl_feat=%f\t%f\t%f\t%f\n', t1, t2, t3, t4);
            %fastkmeans, k_means, MATLAB time=0.091441	0.223734	523.839153

            minDistance = min(D, [], 2);

            clusteringScores = 1 ./ minDistance;
            elapsed = toc(bsTime);
            fprintf(1,'Entropy time=%f\n',elapsed);
        end
    end
    
    methods (Static)
        function msg = desc
            msg = ['Implements the AL algorithm for sentiment analysis from "Using crowdsourcing and active learning to track sentiment in online media"' ...
                    ' by Brew, Anthony; Greene, Derek; Cunningham, Pádraigby Burr Settles, page 15.\n' ...
                    'Items that are closer to a cluster''s centroid are more likely to be selected.'];
        end
    end
    
end


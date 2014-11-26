classdef OptimalCrowdManager < handle
    properties
        INITIAL_WEIGHT = 1;
        numberOfItems = 0;
        primaryKeyIndex = 0;
        realLabelIndex = 0;
        crowdLabelIdx = [];
        crowdUserIdx = [];
        featureIdx = [];
        primaryKeys = [];
        realLabels = [];
        crowdUsers = [];
        crowdLabels = [];
        features = [];
        blockedUsers = []; %java.util.Hashtable;
        usersWeights = []; %java.util.Hashtable;
        usersIntId = []; %java.util.Hashtable;
        simulateTheCrowd = false;
        wholeData = [];
        visFormat = nan;
        cmRandStream = [];
    end %properties
    
    methods
        %constructor: The constrctor for now only needs the .dat file. We
        %will need the .details file only at the time of log replaying
        function obj = OptimalCrowdManager(filename, primaryKeyIndex, realLabelIndex, crowdUserIdx, crowdLabelIdx, featureIdx, simulateTheCrowd, balancedLabels, cmRandStream, shuffle)
            loadingTime = tic;
            obj.cmRandStream = cmRandStream;
            [pathstr, basename, ext] = fileparts(filename);
            if strcmp(ext, '.dat') % mixed numbers and string
                visFormat = false;
            elseif strcmp(ext, '.vis') % vision format: numbers and strings are in separate files
                visFormat = true;
            else
                error(['Unsupported format: ' ext]);
            end
            
            if ~visFormat % mixed numbers and string
                data = loadcell(filename, ',', '"');
            else % vision format: numbers and strings are in separate files
                try % check if it's matlab format
                    data = load(filename, '-mat');
                    data = data.dataset;
                catch % if not, maybe it is still in ASCII format
                    data = load(filename, '-ascii');                    
                end
                if ~simulateTheCrowd
                    str_data = loadcell([pathstr basename '.crd'], ',', '"'); % this .crd is the file holding the string fields
                    assert(size(str_data,1) == size(data,1));
                end
            end
            if balancedLabels
                if ~visFormat
                    tempReal = cell2mat(data(:,realLabelIndex));
                else
                    tempReal = data(:,realLabelIndex);
                end
                ulabels = unique(tempReal);
                minLabs = Inf;
                for i=1:length(ulabels)
                    minLabs = min([minLabs length(find(tempReal==ulabels(i)))]);
                end
                % now we need to keep only minLabs random occurrences of each unique value of the labels
                keepIdx = [];
                for i=1:length(ulabels)
                    newIdx = randsample(cmRandStream, find(tempReal==ulabels(i)), minLabs, false);
                    keepIdx = [keepIdx; newIdx];
                end
                data = data(keepIdx,:);
                if visFormat && ~simulateTheCrowd
                    str_data = str_data(keepIdx, :);
                end
            end
            if shuffle
                rndIdx = cmRandStream.randperm(size(data,1));
                data = data(rndIdx,:);
                if visFormat && ~simulateTheCrowd
                    str_data = str_data(rndIdx, :);
                end
            end
            obj.blockedUsers = java.util.Hashtable;
            obj.usersWeights = java.util.Hashtable;
            obj.usersIntId = java.util.Hashtable;
            obj.numberOfItems = size(data,1);
            obj.primaryKeyIndex = primaryKeyIndex;
            obj.realLabelIndex = realLabelIndex;
            obj.crowdUserIdx = crowdUserIdx;
            obj.crowdLabelIdx = crowdLabelIdx;
            obj.featureIdx = featureIdx;
            obj.simulateTheCrowd = simulateTheCrowd;
            if visFormat
                obj.primaryKeys = data(:,primaryKeyIndex);
                obj.realLabels = data(:,realLabelIndex);
                if ~simulateTheCrowd
                    obj.crowdUsers = str_data(:, obj.crowdUserIdx);
                    obj.crowdLabels = cell2mat(str_data(:, obj.crowdLabelIdx));
                end
                obj.features = data(:,featureIdx);
            else
                obj.primaryKeys = cell2mat(data(:,primaryKeyIndex));
                obj.realLabels = cell2mat(data(:,realLabelIndex));
                obj.crowdUsers = data(:, obj.crowdUserIdx);
                obj.crowdLabels = cell2mat(data(:, obj.crowdLabelIdx));
                obj.features = cell2mat(data(:,featureIdx));
            end
            obj.visFormat = visFormat;
            obj.wholeData = data;
            
            %if length(obj.featureIdx)>5000
            %    M = obj.features;
            %    [U S V] = svds(M, 50);
                %obj.features = U * S * V';
            %    obj.features = U;
            %end
                        
            for i=1:size(obj.crowdUsers,1)
                for u=1:size(obj.crowdUsers,2)
                    user = char(obj.crowdUsers(i,u));
                    if ~obj.usersWeights.containsKey(user)
                        obj.usersWeights.put(user, obj.INITIAL_WEIGHT);                      
                    end
                    if ~obj.usersIntId.containsKey(user)
                        obj.usersIntId.put(user, obj.usersIntId.size+1);
                    end
                end
            end
            elapsed = toc(loadingTime);
            fprintf(1, 'Loading data into the CrowdManager took %d secs.\n', elapsed);
        end

        function indexRange = mapPrimaryKeyToIndex(obj, primKeys)
            indexRange = zeros(size(primKeys));
            for i=1:length(primKeys)
                indexRange(i) = find(obj.primaryKeys==primKeys(i));
            end 
        end
        
        
        function realLabels = getRealLabelsByPrimaryKey(obj, primKeys)
            indexRange = obj.mapPrimaryKeyToIndex(primKeys);
            realLabels = obj.getRealLabels(indexRange);
        end
        
        function crowdLabels = getCrowdLabelsByPrimaryKey(obj, primKeys, howManyEach, useWeights)
            indexRange = obj.mapPrimaryKeyToIndex(primKeys);
            if nargin==2
                crowdLabels = obj.getCrowdLabels(indexRange);
            elseif nargin==3
                crowdLabels = obj.getCrowdLabels(indexRange, howManyEach);
            elseif nargin==4
                crowdLabels = obj.getCrowdLabels(indexRange, howManyEach, useWeights);
            end
        end

        function crowdLabels = getCrowdLabels(obj, indexRange, howManyEach, useWeights)
            if obj.simulateTheCrowd
                crowdLabels = getRealLabels(obj, indexRange);
                return;
            end
            
            if nargin==2
                howManyEach = length(obj.crowdLabelIdx);
                useWeights = false;
            elseif nargin==3
                useWeights = false;
            end
            if isscalar(howManyEach)
                howManyEach = repmat(howManyEach, size(indexRange));
            end
            
            crowdLabels = zeros(length(indexRange),1);
            for i=1:length(indexRange)
                idx = indexRange(i);
                if ~useWeights
                    crowdLabels(i,:) = mode(obj.crowdLabels(idx, 1:howManyEach(i)));
                else
                    users = obj.crowdUsers(idx, 1:howManyEach(i));
                    usersW = zeros(size(users));
                    for u=1:length(users)
                        usersW(u) = obj.usersWeights.get(char(users(u)));
                    end
                    crowdLabels(i,:) = round( (obj.crowdLabels(idx, 1:howManyEach(i)) * usersW') / sum(usersW));                        
                end
            end
        end % getCrowdLabels
        
        function crowdLabels = getIndividualCrowdLabels(obj, indexRange, howMany)
            if nargin==2
                howMany = length(obj.crowdLabelIdx);
            end
            
            if obj.simulateTheCrowd
                crowdLabels = repmat(getRealLabels(obj, indexRange), 1, howMany);
                return;
            end
            
            crowdLabels = zeros(length(indexRange), howMany);
            for i=1:length(indexRange)
                idx = indexRange(i);
                crowdLabels(i,:) = obj.crowdLabels(idx, 1:howMany);
            end
        end % getIndividualCrowdLabels
        
        function realLabels = getRealLabels(obj, indexRange)
            realLabels = obj.realLabels(indexRange,:);
        end % getRealLabels

        function data = getData(obj, indexRange)
            data = obj.features(indexRange,:);
        end % getRealLabels

        function data = getPrimaryKeys(obj, indexRange)
            data = obj.primaryKeys(indexRange,:);
        end % getRealLabels        
        
        function updateWeights(obj, indexRange, baseLineValue, deltaFuncIfNotEqualToBaseline)
            for i=1:length(indexRange)
                idx = indexRange(i);
                users = obj.crowdUsers(idx, :);
                for u=1:length(users)
                    curW = obj.usersWeights.get(char(users(u)));
                    if obj.crowdLabels(idx,u) ~= baseLineValue(i)
                        curW = deltaFuncIfNotEqualToBaseline(i, curW);
                        obj.usersWeights.put(char(users(u)), curW);
                    end
                end
            end
        end %update weightsx

        function [howManyGroups howManyInEachGroup groups groupsKey] = findUniqueValues(obj, attributeIdx)
            if isempty(attributeIdx) % we need to group by user!
                buildFaceUserGroup;
                return;
            end
            
            groups = zeros(obj.numberOfItems, obj.numberOfItems);
            howManyInEachGroup = [];
            groupNumbers = java.util.Hashtable;
            groupsKey = {};
            nextGroupId = 1;
            for i=1:obj.numberOfItems
                key = num2str(obj.wholeData(i,attributeIdx));
                if groupNumbers.containsKey(key)
                    gid = groupNumbers.get(key);                    
                    howManyInEachGroup(gid) = howManyInEachGroup(gid) +1;
                    groups(gid, howManyInEachGroup(gid)) = i;
                else
                    gid = nextGroupId;
                    groupNumbers.put(key, gid);
                    howManyInEachGroup(gid) = 1;
                    groups(gid, 1) = i;
                    groupsKey{end+1} = key;
                    
                    nextGroupId = nextGroupId +1;
                end
            end
            howManyGroups = length(howManyInEachGroup);
            assert(howManyGroups == nextGroupId-1);
        end % findUniqueValues
        
        function [estimated_error userPerGroupErrorProb true_error howManyGroups howManyInEachGroup groups groupsKey] = estimateWorkerAccuracies(obj, attributeIdx, initialRowsPerGroup, initialRedundancy, removeInitialItems)
            [howManyGroups howManyInEachGroup groups groupsKey] = findUniqueValues(obj, attributeIdx);
            userPerGroupMistakes = zeros(obj.usersIntId.size, howManyGroups);
            userPerGroupLabels = zeros(obj.usersIntId.size, howManyGroups);            
            userPerGroupErrorProb = zeros(obj.usersIntId.size, howManyGroups);            
            userPerGroupErrorProb(:,:) = nan;
            
            maxLabels = length(obj.crowdUserIdx);
            assert(initialRedundancy<=maxLabels);
            for gid=1:howManyGroups
                k = min(initialRowsPerGroup, howManyInEachGroup(gid));
                thisGroup = groups(gid, 1:howManyInEachGroup(gid));
                chosen = randsample(obj.cmRandStream, thisGroup, k, false);
                if removeInitialItems
                    howManyInEachGroup(gid) = howManyInEachGroup(gid) -k;
                    groups(gid, 1:howManyInEachGroup(gid)) = setdiff(thisGroup, chosen);
                    groups(gid, howManyInEachGroup(gid)+1:end) = 0;
                end
                
                for cidx=1:length(chosen)
                    ci = chosen(cidx);
                    trueLabel = getRealLabels(obj, ci);
                    whichUsers = randsample(obj.cmRandStream, maxLabels, initialRedundancy, false);
                    for uidx=1:length(whichUsers)
                        ui = whichUsers(uidx);
                        user = char(obj.crowdUsers(ci,ui));
                        userId = obj.usersIntId.get(user);
                        userLabel = obj.crowdLabels(ci,ui);
                        userPerGroupLabels(userId, gid) = userPerGroupLabels(userId, gid) +1;
                        if userLabel~=trueLabel
                            userPerGroupMistakes(userId, gid) = userPerGroupMistakes(userId, gid) +1;
                        end
                    end
                end
                userPerGroupErrorProb(:, gid) = userPerGroupMistakes(:, gid) ./ userPerGroupLabels(:, gid);
            end % gid
            %now we have the error rates of each user/grp as well as how often they work!
            
            true_error = zeros(howManyGroups, maxLabels);
            for gid=1:howManyGroups
                for redundancy=1:maxLabels
                    thisGroup = groups(gid, 1:howManyInEachGroup(gid));
                    rl = getRealLabels(obj, thisGroup);
                    % from here
                    all_cl = getIndividualCrowdLabels(obj, thisGroup, maxLabels);
                    err_iter = zeros(0,1);
                    for iter=1:1
                        subset_cl = zeros(length(thisGroup), redundancy);
                        parfor item=1:length(thisGroup)
                            subset_cl(item, :) = randsample(obj.cmRandStream, all_cl(item, :), redundancy);
                        end    
                        cl = mode(subset_cl, 2);
                        err_iter(end+1) = length(find(rl~=cl)) / length(rl);
                    end
                    true_error(gid, redundancy) = mean(err_iter);
                    % to here
                    % cl = getCrowdLabels(obj, thisGroup, redundancy);
                    % true_error(gid, redundancy) = length(find(rl~=cl)) / length(rl);
                    fprintf(1, 'r=%d ', redundancy);
                end
                fprintf(1, '\nfinished worker accuracy for gid=%d\n', gid);
            end
            
            %let's estimate the error per sub-group/redundancy
            estimated_error = zeros(howManyGroups, maxLabels);

            parfor gid=1:howManyGroups
                for redundancy=1:maxLabels
                    estimated_error(gid, redundancy) = probMajorityMistake(userPerGroupErrorProb(:, gid), userPerGroupLabels(:, gid), redundancy, obj.cmRandStream);
                end
            end
            
        end % function
        
        function [budgets projectedUniformError projectedPbaError optimalAssignmentPerGroup] = solveOptimalAllocation(obj, errorMatrix, groupFreq, groupsKey)
            howManyGroups = size(errorMatrix, 1);
            maxLabels = length(obj.crowdUserIdx);
            assert(length(groupsKey)==howManyGroups && length(groupFreq)==howManyGroups);
            assert(maxLabels==size(errorMatrix,2));
            
            weighted_error = errorMatrix;
            for gid=1:howManyGroups
                weighted_error(gid,:) = weighted_error(gid,:) * groupFreq(gid);
            end
            
            Aeq = zeros(howManyGroups, howManyGroups*maxLabels);
            for gid=1:howManyGroups
                sumMat = zeros(howManyGroups, maxLabels);
                sumMat(gid,:)=1;
                sumMat = reshape(sumMat, howManyGroups*maxLabels, 1);
                Aeq(gid,:) = sumMat;
            end
            Beq = ones(howManyGroups, 1);            
            
            cost = zeros(howManyGroups, maxLabels);
            for gid=1:howManyGroups
                cost(gid,:) = groupFreq(gid) * (1:maxLabels);
            end
            A = reshape(cost, 1, howManyGroups*maxLabels);
            
            optimalAssignmentPerGroup = zeros(howManyGroups, maxLabels); % if budget(gid,b) ==3, it means that when overall budget is 3x, we will assign 3 labels for guys of group gid
            
            f = reshape(weighted_error, howManyGroups*maxLabels, 1);
            totalFreq = sum(groupFreq);            
            projectedPbaError = zeros(maxLabels, 1);
            projectedUniformError = zeros(maxLabels, 1);
            budgets = (1:maxLabels)';
            
            
            for redundancy=1:maxLabels
                b = redundancy*totalFreq;
                ilpTime = tic;
                x = bintprog(f, A, b, Aeq, Beq);
                ilpRunTime = toc(ilpTime);
                fprintf(1, 'bintprog=%d\n', ilpRunTime);
                x = round(x);
                projectedPbaError(redundancy) = f'*x / totalFreq;
                projectedUniformError(redundancy) = sum(weighted_error(:, redundancy),1) /totalFreq;
                
                for gid=1:howManyGroups
                    sol = reshape(x, howManyGroups, maxLabels);
                    sol = sol(gid,:);
                    optimalAssignmentPerGroup(gid, redundancy) = find(sol==1);            
                end
            end
        end % function
        
    end %methods
    
end %classdef




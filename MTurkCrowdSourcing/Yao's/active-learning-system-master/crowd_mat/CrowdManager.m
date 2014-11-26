classdef CrowdManager < handle
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
        itemWeights = [];
        blockedUsers = []; %java.util.Hashtable;
        usersWeights = []; %java.util.Hashtable;
        simulateTheCrowd = false;
        inputFilePath = '';
    end %properties
    
    methods
        %constructor: The constrctor for now only needs the .dat file. We
        %will need the .details file only at the time of log replaying
        function obj = CrowdManager(filename, primaryKeyIndex, realLabelIndex, crowdUserIdx, crowdLabelIdx, featureIdx, simulateTheCrowd, balancedLabels, cmRandStream, shuffle, inputfile)
            loadingTime = tic;
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
                data = data(keepIdx,:);s
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
            obj.numberOfItems = size(data,1);
            obj.primaryKeyIndex = primaryKeyIndex;
            obj.realLabelIndex = realLabelIndex;
            obj.crowdUserIdx = crowdUserIdx;
            obj.crowdLabelIdx = crowdLabelIdx;
            obj.featureIdx = featureIdx;
            obj.simulateTheCrowd = simulateTheCrowd;
            obj.inputFilePath = inputfile;
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
            %TODO: For now, we assume the original datasets do not have
            %weights! so we assign a uniform weight of 1 to every item
            %initially
            obj.itemWeights = ones(obj.numberOfItems, 1);
            
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
        
        function realLabels = getRealLabels(obj, indexRange)
            realLabels = obj.realLabels(indexRange,:);
            numUndefined = length(realLabels(realLabels == -1));
            if  numUndefined > 0
                tempKeys = obj.primaryKeys(indexRange,:);
                undefinedKey = tempKeys(realLabels == -1);
                jsonFile = loadjson(obj.inputFilePath);
                jsonFile.keys_of_selected = char(num2str(undefinedKey'));

                savejson('', jsonFile, obj.inputFilePath);
                conn = database('activeLearner','root','',...
                'Vendor','MySQL',...
                'Server','localhost');
                curs = exec(conn,'UPDATE doJava SET runJava=1 where runJava = 0');
                javaDone = 0;
                while javaDone == 0
                    curs = exec(conn,'select * from doJava;');
                    curs = fetch(curs);
                    if cell2mat(curs.Data) == 0
                        javaDone = 1;
                    else
                        pause(5);
                    end
                end
                curs = exec(conn,'select count(*) from resultT;');
                curs = fetch(curs);
                cursResult = exec(conn,'select * from resultT;');
                cursResult = fetch(cursResult);
                for j = 1:cell2mat(curs.Data)
                    obj.realLabels(obj.primaryKeys == cell2mat(cursResult.Data(j))) =  cell2mat(cursResult.Data(j,2));
                end
            end
        end % getRealLabels

        function data = getData(obj, indexRange)
            data = obj.features(indexRange,:);
        end % getData
        
        function data = getDataWeights(obj, indexRange)
            data = obj.itemWeights(indexRange,:);
        end % getDataWeights

        function data = getPrimaryKeys(obj, indexRange)
            data = obj.primaryKeys(indexRange,:);
        end        
        
        function nFeatures = getNFeatures(obj)
            nFeatures = length(obj.featureIdx);
        end
        
        function nRows = getNRows(obj)
            nRows = obj.numberOfItems;
        end

        function updateDataWeights(obj, indexRange, newValues)
            assert(length(indexRange)==length(newValues) || isscalar(newValues));
            if ~isempty(indexRange)
                obj.itemWeights(indexRange,:) = newValues;
            end
        end
        
        function updateUserWeights(obj, indexRange, baseLineValue, deltaFuncIfNotEqualToBaseline)
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

    end %methods
    
end %classdef




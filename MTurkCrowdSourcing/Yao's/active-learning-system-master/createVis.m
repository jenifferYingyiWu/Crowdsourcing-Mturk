function createVis (filename, datafileName, username, inputFilePath)

%     filename = 'face10.updatedDetails';
%     datafileName = 'new2.vis';
%     username = 'lslsheng';

    fileID = fopen(sprintf('/opt/lampp/htdocs/mturk/uploads/%s',filename));
    C = textscan(fileID,'%s %s %s');
    fclose(fileID);

    largest = 0;
    dimension = numel(size(double(imread(C{2}{2}))));


    for i = 2:length(C{2})
        a = size(double(imread(C{2}{i})));
        if largest < prod(a)
            largest = prod(a);
        end
    end

    visLength = 2 + dimension + largest;
    visFile = zeros(length(C{2}) - 1, visLength);


    for i = 1:length(C{2})
        visFile(i,1) = str2num(C{1}{i});
        visFile(i,2) = str2num(C{3}{i});
        img = double(imread(C{2}{i}));
        a = size(img);
        for j = 1:dimension
            visFile(i,j + 2) = a(j);
        end
        visFile(i, 3 + dimension : visLength) = img(:);
    end


    dlmwrite(sprintf('crowd_data/uci-datasets/%s', datafileName),visFile);

    configFile = load('crowd_GUI/config-files/conf1.mat');
    configFormat = configFile.file_conf_info.ds_conf_map.format;
    configFormat.featureCols = [2 + dimension + 1:visLength];
    configFormat.datafile = datafileName;
    configFormat.inputFilePath = inputFilePath;
    tempCell = cell(1);
    tempCell{1} = 'glass';
    configFile.file_conf_info.dss_Icare = tempCell;
    configFile.file_conf_info.ds_conf_map.glass = configFormat;
    file_conf_info = configFile.file_conf_info;

    save(sprintf('../../../users/%s/conf1.mat', username), 'file_conf_info');

end

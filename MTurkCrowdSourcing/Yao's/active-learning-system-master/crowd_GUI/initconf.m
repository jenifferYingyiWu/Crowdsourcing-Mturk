function initconf(name)

global cur_conf;
cur_conf = name;

init_dataset_configs;


dss_available = dss_available_conf;

alsFull_available = getActiveLearners();

al_Full_map = struct;
for i=1:length(alsFull_available)
    al_Full_map.(getAcronym(alsFull_available{i}))=alsFull_available{i};
end

als_available = fieldnames(al_Full_map).';

dss_Icare = {};

als_Icare = {};

doOneStep = false;

doIterative = false;

doIterativeIID = false;

randSeed = 12345;


ds_info_map = struct;
for i=1:length(dss_available)
    ds_info_map.(dss_available{i}) = makeDSInfo();
end

al_info_map = struct;
for i=1:length(als_available)
    al_info_map.(als_available{i}) = makeALInfo(al_Full_map.(als_available{i}));
end

ds_conf_map = struct;

for i = 1:length(dss_available)
    try
        tmp_conf = eval([dss_available{i} '_conf']);
    catch
        error(['dataset ' dss_available{i} ' does not have _conf file!']);
    end
    ds_conf_map.(dss_available{i}) = addDefaultFields(tmp_conf,dss_available{i});
end

for i = 1:length(dss_Icare)
    try
        tmp_conf = eval([dss_Icare{i} '_conf']);
    catch
        error(['dataset ' dss_Icare{i} ' does not have _conf file!']);
    end
    ds_conf_map.(dss_Icare{i}) = addDefaultFields(tmp_conf,dss_Icare{i});
end

classifiers = getClassifiers();

file_conf_info = struct;



saveconf;

end


global cur_conf;
s = what('config-files');
s = s.path;
load([s '/' cur_conf]);

dss_available = file_conf_info.dss_available;
alsFull_available = file_conf_info.alsFull_available;
al_Full_map = file_conf_info.al_Full_map;
als_available = file_conf_info.als_available;
dss_Icare = file_conf_info.dss_Icare;
als_Icare = file_conf_info.als_Icare;
doOneStep = file_conf_info.doOneStep;
doIterative = file_conf_info.doIterative;
doIterativeIID = file_conf_info.doIterativeIID;
randSeed = file_conf_info.randSeed;
ds_info_map = file_conf_info.ds_info_map;
al_info_map = file_conf_info.al_info_map;
ds_conf_map = file_conf_info.ds_conf_map;
classifiers = file_conf_info.classifiers;

clear s;
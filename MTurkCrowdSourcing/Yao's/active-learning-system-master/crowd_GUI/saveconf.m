
global cur_conf
s = what('config-files');
s = s.path;


file_conf_info.dss_available = dss_available;
file_conf_info.alsFull_available = alsFull_available;
file_conf_info.al_Full_map = al_Full_map;
file_conf_info.als_available = als_available;
file_conf_info.dss_Icare = dss_Icare;
file_conf_info.als_Icare = als_Icare;
file_conf_info.doOneStep = doOneStep;
file_conf_info.doIterative = doIterative;
file_conf_info.doIterativeIID = doIterativeIID;
file_conf_info.randSeed = randSeed;
file_conf_info.ds_info_map = ds_info_map;
file_conf_info.al_info_map = al_info_map;
file_conf_info.ds_conf_map = ds_conf_map;
file_conf_info.classifiers = classifiers;

save([s '/' cur_conf],'file_conf_info');

clear s dss_available als_available dss_Icare als_Icare doOneStep doIterative...
    doIterativeIID randSeed ds_info_map al_info_map ds_conf_map classifiers...
    al_Full_map file_conf_info;
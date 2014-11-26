active-learning-system
======================

A general purpose, extensible system for Active Learning


INSTALL:

You need to download the following libraries and add them to your mathlab's path:

Common-Libs:
	https://github.com/barzan/common-libs

To get familiar with the source code, the best starting point is the following function:
	On Linux:
		sudo echo -e "\nrun('~/.matlab/startup.m');" >> MATLABROOT/toolbox/local/matlabrc.m
		cp common-libs/common_mat/startup.m ~/.matlab/



https://github.com/mozafari/active-learning-system/blob/master/crowd_mat/runUCIclass.m

You can run this function with:
runUCIclass(1, 1, 0, {'var'}, {'glass'});

UPDATE GUI:

RUN IN COMMAND LINE:

Call run_conf(‘conf1.mat’) where conf1.mat is any configuration file in /crowd_GUI/config-files/

EDIT THE CONFIGURATION FILE:

The easiest way is to edit in the GUI.

Also you can do the following in the command line:
global cur_conf;
cur_conf =  ‘conf1.mat’;//make sure “conf1.mat” is in /crowd_GUI/config-files/
loadconf;
//make any changes to the workspace variables
saveconf;

START THE GUI:

Type “start_GUI” in the command window, and the GUI will start.

Make sure any incoming configuration file is located under /crowd_GUI/config-files/, so that the GUI can detect it and load it. 

Notice:
1. If you ever add/delete any ActiveLearner/Classifier, or modify the function parameters of any ActiveLearner constructor, all previous configuration files are no longer valid. You should remove those “.mat” files and start the GUI to create a fresh configuration.
2. The classifier field of any ActiveLearner must be named “classifier”, not “learner” or others.

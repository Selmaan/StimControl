%% Select ROIs
StimROIs = [];
roiSelector;
%% Parameters
sHz = 1e5;
repeats = 30;
ITI = 30;
%% Generate Trials
paramTestTrials
%% Generate Experiment
global stimExpt
stimExpt = genExpt(StimROIs,trials,repeats,ITI);
runExpt;
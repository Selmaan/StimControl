%% Select ROIs
global StimROIs
StimROIs = [];
roiSelector;
%% Parameters
sHz = 1e5;
repeats = 15;
ITI = 60;
%% Generate Trials
powerTestTrials
%% Generate Experiment
global stimExpt
stimExpt = genExpt(StimROIs,trials,repeats,ITI);
runExpt;
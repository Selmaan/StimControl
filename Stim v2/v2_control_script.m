%% Select ROIs
global StimROIs
StimROIs = [];
roiSelector;
%% Parameters
sHz = 1e5;
repeats = 5;
%% Generate Trials
%pockDutyTestTrials
powerTestTrials;
%% Generate Experiment
global stimExpt
stimExpt = genExpt(StimROIs,trials,repeats,ITI);
runExpt;
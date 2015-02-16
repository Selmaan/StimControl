%% Select ROIs
global StimROIs
StimROIs = [];
roiSelector;
%% Parameters
sHz = 1e5;
repeats = 2;
%% Generate Trials
pockDutyTestTrials
%% Generate Experiment
global stimExpt
stimExpt = genExpt(StimROIs,trials,repeats,ITI);
runExpt;
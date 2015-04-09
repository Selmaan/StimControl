%% Select ROIs
global StimROIs
StimROIs = [];
roiSelector;
%% Parameters
save('temp','StimROIs')
sHz = 1e5;
repeats = 20;
%% Generate Trials
%pockDutyTestTrials
targetTestTrials;
%% Generate Experiment
global stimExpt
stimExpt = genExpt(StimROIs,trials,repeats,ITI);
runExpt;
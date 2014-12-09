%% Parameters

sHz = 1e5;

%% Select ROIs
roiSelector;

%% Generate Trials

targList = 1:length(StimROIs.targ);
trialParams.sHz = sHz;
trialParams.stimFreq = 15;
trainTrial = trialParams;
stimTrial = trialParams;
trainTrial.nStim = 8;
stimTrial.nStim = 1;

[trials, stimParams] = genTrial(StimROIs,1,trainTrial);
for nTarg = targList
    trials(end+1) = genTrial(StimROIs,nTarg,trainTrial,stimParams);
    trials(end+1) = genTrial(StimROIs,nTarg,stimTrial,stimParams);
end
trials(1) = [];

%% Generate Experiment
repeats = 30;
ITI = 30;

global stimExpt
stimExpt = genExpt(StimROIs,trials,repeats,ITI);
runExpt;

%% Save data 
stimFile = [hSI.loggingFullFileName(1:end-3) 'mat'];
stimExpt.StimControl = [];
save(stimFile,'stimExpt')
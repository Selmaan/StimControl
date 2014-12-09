%% Parameters

sHz = 1e5;

%% Select ROIs
StimROIs = [];
roiSelector;

%% Generate Trials

trialParams = [];
trialParams.sHz = sHz;
trialParams.stimFreq = 15;
trainTrial = trialParams;
stimTrial = trialParams;
trainTrial.nStim = 8;
stimTrial.nStim = 1;
[~, stimParams] = genTrial(StimROIs,1,trainTrial);

stimShort = stimParams;
stimShort.dur = 15e-3;
stimLong = stimParams;
stimPulse = stimParams;
stimPulse.pockPulseFreq = 1e4;
stimPulse.pockPulseDuty = 50;
stimWeak = stimParams;
stimWeak.pockPow = 0.9;

trials = repTrials(StimROIs,trainTrial,stimLong);
trials = repTrials(StimROIs,stimTrial,stimLong,trials);
trials = repTrials(StimROIs,trainTrial,stimShort,trials);
trials = repTrials(StimROIs,stimTrial,stimShort,trials);
trials = repTrials(StimROIs,trainTrial,stimPulse,trials);
trials = repTrials(StimROIs,stimTrial,stimPulse,trials);
trials = repTrials(StimROIs,trainTrial,stimWeak,trials);
trials = repTrials(StimROIs,stimTrial,stimWeak,trials);
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
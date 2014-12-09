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
    %trials(end+1) = genTrial(StimROIs,nTarg,stimTrial,stimParams);
end
trials(1) = [];

%% Generate Experiment
repeats = 20;
ITI = 30;

global stimExpt
stimExpt = genExpt(trials,repeats,ITI);
runExpt;

% rewrite runExpt using callbacks so that command line access isn't blocked
% during experiment


% Experiment needs to generate sequential order of trials, and handle AO
% tasks such as :
% create NI daq tasks for experimental control
% opening or closing shutter (if desired)
% Prepositioning mirrors on next targeted cell, before stim is initiated
% setting up an appropriate 'trial counter' (e.g. 30-frame counter to output a pulse every second)
% loading signals onto hardware and set up triggers, before appropriate trigger
% save information pertaining to which stimulations happened when

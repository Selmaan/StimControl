function stimExpt = genExpt(StimROIs,trials,repeats,ITI)
% Function to generate a stimulation experiment from
%
% stimExpt = genExpt(StimROIs,trials,repeats,ITI)
%
% StimROIs is the output of roiSelector GUI
% trials is a 1xn structure of trial structures
% repeats is a positive number indicating number of stim trials for each target
% ITI is a positive number indicating # of frames btw each trial (e.g. 30 for ~1 trial/second)
% stimExpt is an optional 

stimExpt.sHz = trials(1).sHz;
stimExpt.StimROIs = StimROIs;
stimExpt.trials = trials;
stimExpt.ITI = ITI;
stimExpt.nRepeats = repeats;
stimExpt.trialOrder = [];
for repeat = 1:stimExpt.nRepeats
    stimExpt.trialOrder(repeat,:) = randperm(length(trials));
end
stimExpt.shutterStatus = 'closed';
stimExpt.completed = 0;
stimExpt.started = 0;
    
stimExpt.cRepeat = 1;
stimExpt.cTrial = 1;

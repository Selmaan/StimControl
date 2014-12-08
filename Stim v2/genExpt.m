function stimExpt = genExpt(StimROIs,trials,repeats)

stimExpt.sHz = trials(1).sHz;
stimExpt.StimROIs = StimROIs;
stimExpt.trials = trials;
stimExpt.StimControl = createStimTasks(stimExpt.sHz);
stimExpt.nRepeats = repeats;
for repeat = 1:stimExpt.nRepeats
    stimExpt.trialOrder(repeat,:) = randperm(length(trials));
end
stimExpt.shutterStatus = 'closed';
stimExpt.completed = 0;
stimExpt.started = 0;
    
stimExpt.cRepeat = 1;
stimExpt.cTrial = 1;

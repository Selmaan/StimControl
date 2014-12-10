function stopExpt

global stimExpt

writeDigitalData(stimExpt.StimControl.hStimShutter, 0, 10, true),
stimExpt.shutterStatus = 'closed';
stop(stimExpt.StimControl.fCtr),
stop(stimExpt.StimControl.hStim),
stop(stimExpt.StimControl.hStimPock),
deleteStimTasks,
saveExpt,
fprintf('Experiment Stopped\n'),
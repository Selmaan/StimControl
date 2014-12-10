function runExpt

global stimExpt

stimExpt = createStimTasks(stimExpt);

stimExpt.started = 1;

% set callback
registerDoneEvent(stimExpt.StimControl.hStim,@(src,evnt)cbStimDone(src,evnt)),

% Open shutter
writeDigitalData(stimExpt.StimControl.hStimShutter, 1, 10, true),
stimExpt.shutterStatus = 'open';

% Prepare and start tasks
nTrial = stimExpt.trialOrder(stimExpt.cRepeat, stimExpt.cTrial);
writeAnalogData(stimExpt.StimControl.hStimMirrorPrep,[stimExpt.trials(nTrial).offset(1),stimExpt.trials(nTrial).offset(2)], 10, true),
stop(stimExpt.StimControl.hStimMirrorPrep),
xSig = stimExpt.trials(nTrial).xSig;
ySig = stimExpt.trials(nTrial).ySig;
pSig = stimExpt.trials(nTrial).pSig;
cfgSampClkTiming(stimExpt.StimControl.hStim, stimExpt.sHz, 'DAQmx_Val_FiniteSamps', size(xSig,1)),
cfgSampClkTiming(stimExpt.StimControl.hStimPock, stimExpt.sHz, 'DAQmx_Val_FiniteSamps', size(xSig,1)),
writeAnalogData(stimExpt.StimControl.hStim, [xSig,ySig], 10,false),
writeAnalogData(stimExpt.StimControl.hStimPock, pSig, 10,false),
start(stimExpt.StimControl.hStim),
start(stimExpt.StimControl.hStimPock),
start(stimExpt.StimControl.fCtr),
        
% update display
%no display implemented yet, just print to command line
fprintf('Beginning Experiment. Requires > %.0f frames\n',(1+numel(stimExpt.trialOrder))*stimExpt.ITI),

end


function cbStimDone(src,evnt)

global stimExpt

% Stop stimulation tasks (not incl. counter)
stop(stimExpt.StimControl.hStim),
stop(stimExpt.StimControl.hStimPock),
control(stimExpt.StimControl.hStim,'DAQmx_Val_Task_Unreserve'),

% Find next target, and detect completion of expt or repeat
trialOrder = stimExpt.trialOrder;
stimExpt.cTrial = mod(stimExpt.cTrial+1, size(trialOrder,2)+1);
if stimExpt.cTrial == 0
    stimExpt.cRepeat = mod(stimExpt.cRepeat+1, size(trialOrder,1)+1);
    if stimExpt.cRepeat == 0
        stop(stimExpt.StimControl.fCtr),
        control(stimExpt.StimControl.fCtr,'DAQmx_Val_Task_Unreserve'),
        control(stimExpt.StimControl.hStimPock,'DAQmx_Val_Task_Unreserve'),
        stimExpt.completed = 1;
        writeDigitalData(stimExpt.StimControl.hStimShutter, 0, 10, true),
        stimExpt.shutterStatus = 'closed';
        deleteStimTasks,
        saveExpt,
        fprintf('Experiment Complete\n'),
        return
    end
    fprintf('Starting Repeat %03.0f\n',stimExpt.cRepeat),
    stimExpt.cTrial = 1;
end

nTrial = trialOrder(stimExpt.cRepeat, stimExpt.cTrial);

% Position Mirrors
writeAnalogData(stimExpt.StimControl.hStimMirrorPrep,[stimExpt.trials(nTrial).offset(1),stimExpt.trials(nTrial).offset(2)], 10, true),
stop(stimExpt.StimControl.hStimMirrorPrep),

% Load signals
xSig = stimExpt.trials(nTrial).xSig;
ySig = stimExpt.trials(nTrial).ySig;
pSig = stimExpt.trials(nTrial).pSig;
cfgSampClkTiming(stimExpt.StimControl.hStim, stimExpt.sHz, 'DAQmx_Val_FiniteSamps', size(xSig,1)),
cfgSampClkTiming(stimExpt.StimControl.hStimPock, stimExpt.sHz, 'DAQmx_Val_FiniteSamps', size(xSig,1)),
writeAnalogData(stimExpt.StimControl.hStim, [xSig,ySig], 10,false),
writeAnalogData(stimExpt.StimControl.hStimPock, pSig, 10,false),

% Start Tasks
start(stimExpt.StimControl.hStim),
start(stimExpt.StimControl.hStimPock),
        
% update display
%no display implemented yet, just print to command line
fprintf('Repeat: %03.0f, targetNum: %03.0f, targetID: %03.0f\n',stimExpt.cRepeat,stimExpt.cTrial,nTrial),

end
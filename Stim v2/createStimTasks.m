function StimControl = createStimTasks(sHz,StimControl)

if ~exist('StimControl','var') || isempty(StimControl)
    StimControl = struct;
else
    deleteStimTasks(StimControl),
end

stimBoardID = 'ExtGalvoUSB';
stimBoard2 = 'si4-2';
StimControl.stimBoardID = stimBoardID;
StimControl.stimBoard2 = stimBoard2;

StimControl.dummy1 = dabs.ni.daqmx.Task('dummyTask1');

StimControl.hStim = dabs.ni.daqmx.Task('X Y Stim');
createAOVoltageChan(StimControl.hStim,stimBoardID,0:1,{'X Mirror','Y Mirror'},-5,5);
cfgSampClkTiming(StimControl.hStim, sHz, 'DAQmx_Val_FiniteSamps', sHz),
cfgOutputBuffer(StimControl.hStim, sHz),
cfgDigEdgeStartTrig(StimControl.hStim, 'PFI0'),

StimControl.hStimPock = dabs.ni.daqmx.Task('Stim Pockels');
createAOVoltageChan(StimControl.hStimPock,stimBoard2,1,{'Stim Pockels'},-5,5);
cfgSampClkTiming(StimControl.hStimPock, sHz, 'DAQmx_Val_FiniteSamps', sHz),
cfgOutputBuffer(StimControl.hStimPock, sHz),
cfgDigEdgeStartTrig(StimControl.hStimPock, 'PFI0'),

StimControl.hStimMirrorPrep = dabs.ni.daqmx.Task('Stim Mirror Pre-positioning');
createAOVoltageChan(StimControl.hStimMirrorPrep,stimBoardID,0:1,{'X Mirror','Y Mirror'},-5,5);

StimControl.hStimShutter = dabs.ni.daqmx.Task('Stim Shutter Toggle');
createDOChan(StimControl.hStimShutter,stimBoardID,'port0/line1');

StimControl.hStimPiezo = dabs.ni.daqmx.Task('Stim Piezo Position');
createAOVoltageChan(StimControl.hStimPiezo,stimBoard2,0,{'Stim Piezo'},-5,5);

StimControl.dummy2 = dabs.ni.daqmx.Task('dummyTask2');

end

function deleteStimTasks(StimControl)
    daqmxTaskSafeClear(StimControl.dummy1)
    daqmxTaskSafeClear(StimControl.hStim)
    daqmxTaskSafeClear(StimControl.hStimPock)
    daqmxTaskSafeClear(StimControl.hStimMirrorPrep)
    daqmxTaskSafeClear(StimControl.hStimShutter)
    daqmxTaskSafeClear(StimControl.hStimPiezo)
    daqmxTaskSafeClear(StimControl.dummy2)
end
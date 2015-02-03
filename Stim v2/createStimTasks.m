function stimExpt = createStimTasks(stimExpt)

%% Delete tasks if previously existed
deleteStimTasks,

%% Set parameters
sHz = stimExpt.sHz;

stimBoardID = 'ExtGalvoUSB';
ctrChanID = 0;
frameClockSrcTerm = 'PFI0';
dividedClockOutTerm = 'PFI1';   % leave empty if exported signal is not needed
stimBoard2 = 'si4-2';
dividedClockInTerm = 'PFI10';
StimControl.stimBoardID = stimBoardID;
StimControl.stimBoard2 = stimBoard2;

frameInterval = stimExpt.ITI;
lowTicks = floor(frameInterval/2);
highTicks = ceil(frameInterval/2);
initialDelay = frameInterval;


%% Create Tasks
StimControl.dummy1 = dabs.ni.daqmx.Task('dummyTask1');

StimControl.fCtr = dabs.ni.daqmx.Task('Frame Clock divider');
StimControl.fCtrChan = StimControl.fCtr.createCOPulseChanTicks(stimBoardID,ctrChanID,'Frame Clock divider',...
    frameClockSrcTerm, lowTicks, highTicks, initialDelay);
StimControl.fCtr.cfgImplicitTiming('DAQmx_Val_ContSamps');
set(StimControl.fCtrChan,'pulseTerm',dividedClockOutTerm);
ctrIntOutTerm = sprintf('/%sInternalOutput',StimControl.fCtrChan.chanNamePhysical);

StimControl.hStim = dabs.ni.daqmx.Task('X Y Stim');
createAOVoltageChan(StimControl.hStim,stimBoardID,0:1,{'X Mirror','Y Mirror'},-5,5);
cfgSampClkTiming(StimControl.hStim, sHz, 'DAQmx_Val_FiniteSamps', sHz),
cfgOutputBuffer(StimControl.hStim, sHz*1.1),
cfgDigEdgeStartTrig(StimControl.hStim, ctrIntOutTerm),

StimControl.hStimPock = dabs.ni.daqmx.Task('Stim Pockels');
createAOVoltageChan(StimControl.hStimPock,stimBoard2,1,{'Stim Pockels'},-5,5);
cfgSampClkTiming(StimControl.hStimPock, sHz, 'DAQmx_Val_FiniteSamps', sHz),
cfgOutputBuffer(StimControl.hStimPock, sHz*1.1),
cfgDigEdgeStartTrig(StimControl.hStimPock, dividedClockInTerm),

StimControl.hStimMirrorPrep = dabs.ni.daqmx.Task('Stim Mirror Pre-positioning');
createAOVoltageChan(StimControl.hStimMirrorPrep,stimBoardID,0:1,{'X Mirror','Y Mirror'},-5,5);

StimControl.hStimShutter = dabs.ni.daqmx.Task('Stim Shutter Toggle');
createDOChan(StimControl.hStimShutter,stimBoardID,'port0/line1');

StimControl.hStimPiezo = dabs.ni.daqmx.Task('Stim Piezo Position');
createAOVoltageChan(StimControl.hStimPiezo,stimBoard2,0,{'Stim Piezo'},-5,5);

StimControl.dummy2 = dabs.ni.daqmx.Task('dummyTask2');

stimExpt.StimControl = StimControl;
end
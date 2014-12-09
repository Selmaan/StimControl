hSys = dabs.ni.daqmx.System();
        
if hSys.taskMap.isKey('XY Stim') %This shouldn't happen in usual operation
    delete(hSys.taskMap('XY Stim'));
end

hStim = dabs.ni.daqmx.Task('XY Stim');
chanObjs = createAOVoltageChan(hStim,'ExtGalvo',0:1,{'X Mirror','Y Mirror'},-5,5);
cfgSampClkTiming(hStim, 1e5, 'DAQmx_Val_FiniteSamps', 2e5),
%cfgDigEdgeStartTrig(hStim, 'PFI0'),

mirCommand = repmat(3*sin(linspace(0,4*pi,2e5))',1,2);
sampsPerChanWritten = writeAnalogData(hStim, mirCommand, 60,true),
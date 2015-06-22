function createFrameCounter2015(src,evt,frameInterval)

taskName = 'Frame Clock Divider';

switch evt.EventName
        case 'seqStimStart'
            m = dabs.ni.daqmx.Task.getTaskMap;
            try
                delete(m(taskName)),
            end
            
            stimBoardID = 'ExtGalvoUSB';
            ctrChanID = 3;
            frameClockSrcTerm = 'PFI8';
            %dividedClockOutTerm = [];   % leave empty if exported signal is not needed
            lowTicks = floor(frameInterval/2);
            highTicks = ceil(frameInterval/2);
            initialDelay = frameInterval;

            fCtr = dabs.ni.daqmx.Task(taskName);
            fCtrChan = fCtr.createCOPulseChanTicks(stimBoardID,ctrChanID,taskName,...
                frameClockSrcTerm, lowTicks, highTicks, initialDelay);
            fCtr.cfgImplicitTiming('DAQmx_Val_ContSamps');
            %set(fCtrChan,'pulseTerm',dividedClockOutTerm);
            
            start(fCtr),
    case 'photostimAbort'
        m = dabs.ni.daqmx.Task.getTaskMap;
        try
            delete(m(taskName)),
        end
end
function FrameCounter_scanAPI(src,evnt,frameInterval)

global hStim hStimPock frameNum stimNum stimFlag sig dummyTask1 dummyTask2

switch evnt.EventName
    
    case 'acquisitionStart'
        frameNum = 0;
        stimNum = 0;
        stimFlag = 1;
        sig = 3*square(linspace(0,2*pi,3e2));
        %sig = repmat(sig',1,2);
        sig = repmat(sig',1,3);
        %sig(:,3) = [ones(size(sig,1)-1,1); 0];
        sHz = 1e4;
        
        dummyTask1 = dabs.ni.daqmx.Task();
        
        hStim = dabs.ni.daqmx.Task('X Y Stim');
        createAOVoltageChan(hStim,'ExtGalvo',0:1,{'X Mirror','Y Mirror'},-5,5);
        cfgSampClkTiming(hStim, sHz, 'DAQmx_Val_FiniteSamps', size(sig,1)),
        cfgDigEdgeStartTrig(hStim, 'PFI0'),
        
        hStimPock = dabs.ni.daqmx.Task('Stim Pockels');
        createAOVoltageChan(hStimPock,'si4-2',1,{'Stim Pockels'},-5,5);
        cfgSampClkTiming(hStimPock, sHz, 'DAQmx_Val_FiniteSamps', size(sig,1)),
        cfgDigEdgeStartTrig(hStimPock, 'PFI0'),
        
        dummyTask2 = dabs.ni.daqmx.Task();
        
        assignin('base','hStimBase',hStim);
        assignin('base','hStimPockBase',hStimPock);
    case 'frameAcquired'
        frameNum = frameNum+1;
        if mod(frameNum,frameInterval) == frameInterval - 1
            start(hStim),
            start(hStimPock),
            stimFlag = 1;
            stimNum = stimNum + 1;
        elseif stimFlag == 1 && isTaskDone(hStim) && isTaskDone(hStimPock)
            stimFlag = 0;
            stop(hStim),
            stop(hStimPock),
            writeAnalogData(hStim, sig(:,1:2), 60,false),
            writeAnalogData(hStimPock, sig(:,3), 60,false),
            control(hStim,'DAQmx_Val_Task_Commit'),
            control(hStimPock,'DAQmx_Val_Task_Commit'),
        end
        
    case {'acquisitionDone' 'acquisitionAborted'}
        stimFlag = 0;
        waitUntilTaskDone(hStim,1),
        waitUntilTaskDone(hStimPock,1),
        
        daqmxTaskSafeClear(dummyTask1);

        if isvalid(hStim)
            clear(hStim),
        end
        if isvalid(hStimPock)
            clear(hStimPock),
        end

        daqmxTaskSafeClear(dummyTask2);
end
end

function daqmxTaskSafeClear(task)
    try
        clkRate = task.sampClkRate; % if this call fails, the task does not exist anymore
        task.clear();
    catch ME
    end
end



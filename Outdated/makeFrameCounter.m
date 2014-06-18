function makeFrameCounter(src,evnt,frameInterval)

global frameNum hStim stimFrames stimNum sig

switch evnt.EventName
        
    case 'acquisitionStart'    
        frameNum = 0;
        stimNum = 0;
        sig = 3*sin(linspace(0,2*pi,2.5e3));
        sig = repmat(sig',1,3);
        sHz = 2.5e5;
        
%         hStim = dabs.ni.daqmx.Task('XY Stim');
%         cfgSampClkTiming(hStim, sHz, 'DAQmx_Val_FiniteSamps', size(sig,1)),
%         cfgDigEdgeStartTrig(hStim, 'PFI0'),
        
        
%         hStim = daq.createSession('ni');
%         addAnalogOutputChannel(hStim,'ExtGalvo',[0 1],'Voltage');
%         addAnalogOutputChannel(hStim,'si4-2',1,'Voltage');
%         trigStim = addTriggerConnection(hStim,'external','ExtGalvo/PFI0','StartTrigger');
%         trigStimPock = addTriggerConnection(hStim,'external','si4-2/PFI0','StartTrigger');
%         hStim.ExternalTriggerTimeout=1e3;
%         hStim.Rate = sHz;
        
    case 'frameAcquired'
         frameNum = frameNum+1;                    
         
         %if (frameNum > frameInterval) && (mod(frameNum,frameInterval) == frameInterval - 1)
         if mod(frameNum,frameInterval) == frameInterval - 1
            stop(hStim)
            writeAnalogData(hStim, sig, 60,true)
            stimNum = stimNum + 1;
            stimFrames(stimNum) = frameNum+1; 
%              queueOutputData(hStim,sig),
%              startBackground(hStim),             
         elseif frameNum == 1
            hStim = dabs.ni.daqmx.Task('X Y Stim');
            sHz = 2.5e5;
            createAOVoltageChan(hStim,'ExtGalvo',0:1,{'X Mirror','Y Mirror'},-5,5);
            cfgSampClkTiming(hStim, sHz, 'DAQmx_Val_FiniteSamps', size(sig,1)),
            cfgDigEdgeStartTrig(hStim, 'PFI0'),
             
%             hStim = daq.createSession('ni');
%             addAnalogOutputChannel(hStim,'ExtGalvo',[0 1],'Voltage');
%             addAnalogOutputChannel(hStim,'si4-2',1,'Voltage');
%             trigStim = addTriggerConnection(hStim,'external','ExtGalvo/PFI0','StartTrigger');
%             trigStimPock = addTriggerConnection(hStim,'external','si4-2/PFI0','StartTrigger');
%             hStim.Rate = sHz;
         end

    case {'acquisitionDone' 'acquisitionAborted'}
        delete(hStim),
        
        %outputSingleScan(hFrameCounter,0), 
        %delete(hStim),
end

        
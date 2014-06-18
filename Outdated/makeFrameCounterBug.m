function makeFrameCounter(src,evnt,frameInterval)

global hStim hStimPock frameNum stimFrames stimNum sig
switch evnt.EventName
        
    case 'acquisitionStart'    
        frameNum = 0;
        stimNum = 0;
        stimFrames = nan(1e4,2);
        %sig = 3*sin(linspace(0,2*pi,2.5e3));
        sig = 3*square(linspace(0,2*pi,3e2));
        sig = repmat(sig',1,2);
        sig(:,3) = [ones(size(sig,1)-1,1); 0];
        sHz = 1e4;
        
        hStim = dabs.ni.daqmx.Task('X Y Stim');
        createAOVoltageChan(hStim,'ExtGalvo',0:1,{'X Mirror','Y Mirror'},-5,5);
        sHz = 2.5e5;
        cfgSampClkTiming(hStim, sHz, 'DAQmx_Val_FiniteSamps', size(sig,1)),
        cfgDigEdgeStartTrig(hStim, 'PFI0'),

%         hStimPock = dabs.ni.daqmx.Task('Stim Pockels');
%         createAOVoltageChan(hStimPock,'si4-2',1,{'Stim Pockels'},-5,5);
%         cfgSampClkTiming(hStimPock, sHz, 'DAQmx_Val_FiniteSamps', size(sig,1)),
%         cfgDigEdgeStartTrig(hStimPock, 'PFI0'),
        
        assignin('base','hStimBase',hStim);
%         assignin('base','hStimPockBase',hStimPock);
        tic,
    case 'frameAcquired'
         frameNum = frameNum+1;                    
         if mod(frameNum,frameInterval) == frameInterval - 1
            stop(hStim),
%             stop(hStimPock),
            writeAnalogData(hStim, sig(:,1:2), 60,true),
%             writeAnalogData(hStimPock, sig(:,3), 60,true),
            stimNum = stimNum + 1;
            %stimFrames(stimNum,:) = [frameNum+1, toc]; 
         end

    case {'acquisitionDone' 'acquisitionAborted'}
        if isvalid(hStim)
            delete(hStim),
        end
%         if isvalid(hStimPock)
%             delete(hStimPock),
%         end
        stimFrames = stimFrames(1:stimNum,:);
end

        
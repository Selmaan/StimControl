function FrameCounter_session(src,evnt,frameInterval)

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
        
        hStim = daq.createSession('ni');
        addAnalogOutputChannel(hStim,'ExtGalvo',[0 1],'Voltage');
        %addAnalogOutputChannel(hStim,'si4-2',1,'Voltage');
        trigStim = addTriggerConnection(hStim,'external','ExtGalvo/PFI0','StartTrigger');
        %trigStimPock = addTriggerConnection(hStim,'external','si4-2/PFI0','StartTrigger');
        hStim.ExternalTriggerTimeout=1e3;
        hStim.Rate = sHz;
        
        assignin('base','hStimBase',hStim);
        tic,
    case 'frameAcquired'
         frameNum = frameNum+1,                    
         if mod(frameNum,frameInterval) == frameInterval - 1
            startBackground(hStim),
            stimNum = stimNum + 1; 
         elseif ~hStim.IsRunning && hStim.ScansQueued == 0
            queueOutputData(hStim,sig(:,1:2)),
            prepare(hStim),
            %stimFrames(stimNum,:) = [frameNum+1, toc]; 
         end

    case {'acquisitionDone' 'acquisitionAborted'}
        stop(hStim),
        delete(hStim),

        stimFrames = stimFrames(1:stimNum,:);
end
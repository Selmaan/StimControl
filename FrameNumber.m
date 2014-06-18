function FrameNumber(src,evnt)

global frameNum stimFrames
switch evnt.EventName
    
    case {'acquisitionStart' 'focusStart'}
        frameNum = 1;
        stimFrames = [];
    case 'frameAcquired'
         frameNum = frameNum+1; 
end
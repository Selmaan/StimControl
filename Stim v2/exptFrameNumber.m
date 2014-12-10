function exptFrameNumber(src,evnt)

global frameNum
switch evnt.EventName
    
    case {'acquisitionStart' 'focusStart'}
        global stimExpt stimFrames
        frameNum = 1;
        stimFrames = [];
        stimExpt.stimFullFile = [evalin('base','hSI.loggingFullFileName(1:end-3)') 'mat'];
    case 'frameAcquired'
         frameNum = frameNum+1;
    case {'acquisitionDone' 'focusDone'}
        global stimData stimFrames
        if ~isempty(stimFrames)
            stimData.stimFrames = stimFrames;
            stimData.EllipsePos = getPosition(stimData.stimROI);
            display(stimData.stimFullFile),
            save(stimData.stimFullFile,'stimData')            
        end
end
function FrameNumber(src,evnt)

global frameNum stimFrames
switch evnt.EventName
    
    case {'acquisitionStart' 'focusStart'}
        frameNum = 1;
        stimFrames = [];
    case 'frameAcquired'
         frameNum = frameNum+1;
    case {'acquisitionDone' 'focusDone'}
        if ~isempty(stimFrames)
            global stimData stimFrames

            if ~isfield(stimData,'saveStimDir') || length(stimData.saveStimDir) == 1
                display('Saving not Formatted'),
                return
            end

            stimData.stimFrames = stimFrames;
            stimData.EllipsePos = getPosition(stimData.stimROI);
            stimData.stimFile = sprintf('%s_%03.0f',stimData.FileBaseName,stimData.acqFileNumber);
            stimData.stimFullFile = fullfile(stimData.saveStimDir,stimData.stimFile);
            display(sprintf(' Saving as: %s \n in: %s',stimData.stimFile,stimData.saveStimDir)),
            save(stimData.stimFullFile,'stimData')            
            stimData.acqFileNumber = stimData.acqFileNumber + 1;
        end
end
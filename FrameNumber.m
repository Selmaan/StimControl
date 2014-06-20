function FrameNumber(src,evnt)

global frameNum stimFrames
switch evnt.EventName
    
    case {'acquisitionStart' 'focusStart'}
        frameNum = 1;
        stimFrames = [];
    case 'frameAcquired'
         frameNum = frameNum+1;
    case 'acquisitionDone'
        if ~isempty(stimFrames)
            global stimData stimFrames saveStimDir

            if isempty(saveStimDir)
                saveStimDir = uigetdir('C:\Data','Stim Data Directory');
            end

            stimData.stimFrames = stimFrames;
            stimData.EllipsePos = getPosition(stimData.stimROI);

            stimFileName = input('Name this Stimulation Trial: ','s');
            saveFullFile = fullfile(saveStimDir,stimFileName);

            save(saveFullFile,'stimData')
        end
end
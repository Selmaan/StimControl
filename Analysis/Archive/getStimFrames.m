function [tV,exF] = getStimFrames(header,stimGroups)

framePer = header.SI.hRoiManager.scanFramePeriod;
ITI = header.SI.hUserFunctions.userFunctionsCfg__2.Arguments{1};
stimOrder = header.SI.hPhotostim.sequenceSelectedStimuli-1;
stimFrameDur = round(stimGroups(end).rois(2).scanfields.duration/framePer);
trainReps = length(stimGroups(end).rois(2:2:end-1));
stimPauseDur = round(stimGroups(end).rois(3).scanfields.duration/framePer);
frameBase = nan(stimFrameDur,trainReps);

for stimFrame = 1:stimFrameDur
    frameBase(stimFrame,:) = stimFrame:(stimFrameDur+stimPauseDur):...
        (stimFrameDur+stimPauseDur)*trainReps;
end
frameBase = frameBase(:);

if isempty(frameBase)
    frameBase = 1;
end

stimStarts = ITI:ITI:ITI*length(stimOrder);
exF = nan(length(frameBase),length(stimStarts));
for stimStart = 1:length(stimStarts)
    stimOn = stimStarts(stimStart);
    exF(:,stimStart) = frameBase-1 + stimOn;
end

for i=1:length(stimOrder)
    tV.nTarg(i) = stimOrder(i);
    tV.stimFrames{i} = exF(:,i);
end
function [tV,exF] = appendStimBlock(fnRes2,block2Offset,tV,exF)

[~,resHeader2] = tiffRead(fnRes2);
[~,stimGroups2] = scanimage.util.readTiffRoiData(fnRes2);
[tV2,exF2] = getStimFrames(resHeader2,stimGroups2);
tV.nTarg = [tV.nTarg,tV2.nTarg];
exF = [exF, exF2+block2Offset];
tV.stimFrames = [tV.stimFrames, ...
    cellfun(@(x)x+block2Offset,tV2.stimFrames,'UniformOutput',false)];
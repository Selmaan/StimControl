function [gLin,rLin,linRA,gRes,resRA,resHeader,roiCentroid,stimGroups] = alignStimExpt(fnRes,fnLin)


%% Read in linear galvo image and convert to global coords
[linImg, linHeader] = tiffRead(fnLin);
linRoiGroup = scanimage.util.readTiffRoiData(fnLin);
linScanfield = linRoiGroup.rois(1).scanfields(1);
gLin = mean(linImg(:,:,1:2:end),3);
rLin = mean(linImg(:,:,2:2:end),3);
linRA = imref2d(size(gLin),[linScanfield.rect(1),linScanfield.rect(1)+linScanfield.rect(3)],...
    [linScanfield.rect(2),linScanfield.rect(2)+linScanfield.rect(4)]);

%% Read in res galvo and convert to global coords
[resImg,resHeader] = tiffRead(fnRes);
gRes = mean(resImg,3);
[hRoiGroup,stimGroups] = scanimage.util.readTiffRoiData(fnRes);
scanfield = hRoiGroup.rois(1).scanfields(1);
resRA = imref2d(size(gRes),[scanfield.rect(1),scanfield.rect(1)+scanfield.rect(3)],...
    [scanfield.rect(2),scanfield.rect(2)+scanfield.rect(4)]);
%% Read in ROI positions

for nROI = 2:length(stimGroups)
    roiCentroid(nROI-1,:) = stimGroups(nROI).rois(2).scanfields.centerXY;
end

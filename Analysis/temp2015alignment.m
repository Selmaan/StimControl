%% Read in linear galvo image and convert to global coords
[linImg, linHeader] = tiffRead(fnLin);
gLin = mean(linImg(:,:,1:2:end),3);
rLin = mean(linImg(:,:,2:2:end),3);
baseLinField = linHeader.SI.hLinScan.fillFractionSpatial/linHeader.SI.hRoiManager.scanZoomFactor;
linScanField = [(1-baseLinField)/2 1-(1-baseLinField)/2];
linRA = imref2d([512 512],linScanField,linScanField);
linTform = affine2d(linHeader.SI.hLinScan.scannerToRefTransform');
[linWarp,linWarpRA] = imwarp(gLin,linRA,linTform);
[rLinWarp,rLinWarpRA] = imwarp(rLin,linRA,linTform);

%% Read in res galvo and convert to global coords
[resImg,header] = tiffRead(fnRes);
gRes = mean(resImg,3);
[hRoiGroup,stimGroups] = scanimage.util.readRoiGroupFromAppendedTiffData(fnRes);
scanfield = hRoiGroup.rois(1).scanfields(1);
scannerToRefTransform = header.SI.hResScan.scannerToRefTransform;
xs = [ 0 1 1 0 ];
ys = [ 0 0 1 1 ];
[xs,ys] = scanfield.transform(xs,ys);
c = scannerToRefTransform * [xs;ys;ones(size(xs))];
xs = c(1,:);
ys = c(2,:);
resRA = imref2d([512 512],[min(xs) max(xs)],[min(ys) max(ys)]);

%% Correct Resonant coordinates to fit with linear

load('SI2015_align'),
res2lin = invert(lin2res);
[resWarp,resWarpRA] = imwarp(gRes,resRA,res2lin);
%% Read in ROI positions

for nROI = 2:length(stimGroups)
    roiCentroid(nROI-1,:) = stimGroups(nROI).rois(2).scanfields.centerXY;
end

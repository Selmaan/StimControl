%% Read in linear galvo image and convert to global coords
[linImg, linHeader] = tiffRead(fnLin);
linRoiGroup = scanimage.util.readRoiGroupFromAppendedTiffData(fnLin);
linScanfield = linRoiGroup.rois(1).scanfields(1);
gLin = mean(linImg(:,:,1:2:end),3);
rLin = mean(linImg(:,:,2:2:end),3);
linRA = imref2d(size(gLin),[linScanfield.rect(1),linScanfield.rect(1)+linScanfield.rect(3)],...
    [linScanfield.rect(2),linScanfield.rect(2)+linScanfield.rect(4)]);

% baseLinField = linHeader.SI.hLinScan.fillFractionSpatial/linHeader.SI.hRoiManager.scanZoomFactor;
% linScanField = [(1-baseLinField)/2 1-(1-baseLinField)/2];
% linRA = imref2d(size(rLin),linScanField,linScanField);
% linTform = affine2d(linHeader.SI.hLinScan.scannerToRefTransform');
% [linWarp,linWarpRA] = imwarp(gLin,linRA,linTform);
% [rLinWarp,rLinWarpRA] = imwarp(rLin,linRA,linTform);

%% Read in res galvo and convert to global coords
[resImg,header] = tiffRead(fnRes);
gRes = mean(resImg,3);
[hRoiGroup,stimGroups] = scanimage.util.readRoiGroupFromAppendedTiffData(fnRes);
scanfield = hRoiGroup.rois(1).scanfields(1);
resRA = imref2d(size(gRes),[scanfield.rect(1),scanfield.rect(1)+scanfield.rect(3)],...
    [scanfield.rect(2),scanfield.rect(2)+scanfield.rect(4)]);

%% Correct Resonant coordinates to fit with linear

load('C:\Users\Selmaan\Documents\GitHub\StimControl\Analysis\SI2015_shortPass-1p3x'),
[resWarp,resWarpRA] = imwarp(gRes,resRA,res2lin);
figure,imshowpair(imNorm(resWarp),resWarpRA,imNorm(gLin),linRA)

% fit new mapping:
% [opt,met] = imregconfig('monomodal');
% opt.MaximumIterations = 1e3;
% opt.MaximumStepLength = 3e-3;
% opt.MinimumStepLength = 1e-6;
% opt.GradientMagnitudeTolerance = 1e-5;
% res2lin = imregtform(imNorm(gRes),resRA,imNorm(gLin),linRA,'affine',opt,met);
% res2lin.T
% [resWarp,resWarpRA] = imwarp(gRes,resRA,res2lin);
% figure,imshowpair(imNorm(resWarp),resWarpRA,imNorm(gLin),linRA)
%% Read in ROI positions

for nROI = 2:length(stimGroups)
    roiCentroid(nROI-1,:) = stimGroups(nROI).rois(2).scanfields.centerXY;
end

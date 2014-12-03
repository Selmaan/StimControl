function StimROIs = px2vROI(StimROIs)

% set/get parameters for mapping reference pixels to mirror voltages
fullscanVrange = 20/3; % full voltage range of stim mirrors at 1x zoom (not centered)
StimROIs.XYmult = [StimROIs.imMeta.acq.scanAngleMultiplierFast, StimROIs.imMeta.acq.scanAngleMultiplierSlow];
[refPixY,refPixX,~] = size(StimROIs.imData);
imPixXY = [refPixX,refPixY];
imscanVrange = fullscanVrange * StimROIs.XYmult / StimROIs.imZoom;

% Loop over ROIs and convert from pixels to volts
nROIs = length(StimROIs.roi);
StimROIs.targ = [];
for nROI = 1:nROIs
    ROIdiam = StimROIs.roi(nROI).elRadius.*2;
    ROIcenter = StimROIs.roi(nROI).elCentroid;
    StimROIs.targ(nROI).diameter = abs(ROIdiam .* imscanVrange ./ imPixXY);
    StimROIs.targ(nROI).offset = ((ROIcenter - 1) .* (imscanVrange./(imPixXY - 1))) - imscanVrange./2;
end
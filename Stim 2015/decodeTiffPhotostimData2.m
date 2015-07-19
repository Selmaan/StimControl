function matchTiffPhotostim2(fnTif,fnPhtstim)
if nargin < 1 || isempty(fnTif)
   [fnTif,pathname] = uigetfile('.tif','Choose path to tif file','file_00001.tif');
   if fnTif==0;return;end
   fnTif = fullfile(pathname,fnTif);
end

if nargin < 2 || isempty(fnPhtstim)
   [fnPhtstim,pathname] = uigetfile('.stim','Choose path to photostim log file',fullfile(pathname,'file_00001.stim'));
   if fnPhtstim==0;return;end
   fnPhtstim = fullfile(pathname,fnPhtstim);
end

%% get image geometry
% get tiff header
[header,Aout, imgInfo] = scanimage.util.opentif(fnTif);

% extract geometry information from tif file
[hRoiGroup,stimGroups] = scanimage.util.readRoiGroupFromAppendedTiffData(fnTif);
assert(length(hRoiGroup.rois) == 1 && length(hRoiGroup.rois.scanfields) == 1,'Tiffs in mRoi mode currently unsupported by this function');

scanfield = hRoiGroup.rois(1).scanfields(1);

switch header.SI.imagingSystem
    case 'Resonant'
        scannerToRefTransform = header.SI.hResScan.scannerToRefTransform;
    case 'Linear'
        scannerToRefTransform = header.SI.hLinScan.scannerToRefTransform;
    otherwise
        error('Unknown imaging system: %s',header.SI.imagingSystem);
end

% corner virtices of image in scanfield coordinates
xs = [ 0 1 1 0 ];
ys = [ 0 0 1 1 ]; 

% transform to scanner coordinates
[xs,ys] = scanfield.transform(xs,ys);

% transform to reference coordinates
c = scannerToRefTransform * [xs;ys;ones(size(xs))];
xs = c(1,:);
ys = c(2,:);
tiftimeseries = header.frameTimestamps;

%% get photostim geometry
header.SI.hPhotostim.sequenceSelectedStimuli;
stimGroups; % defined in reference space
end
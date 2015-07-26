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

xres = scanfield.pixelResolution(1);
yres = scanfield.pixelResolution(2);

% the image extends from 0 to 1 (x and y) in scannfield coordinates
% generate center coordinates for each pixel in scanfield coordinates
[xs,ys] = meshgrid( (1/xres)/2 : 1/xres : 1-(1/xres)/2 ,...
                    (1/yres)/2 : 1/yres : 1-(1/yres)/2 );

% transform pixel centers from scanfield coordinates to reference coordinates
[xs,ys] = scanfield.transform(xs,ys);
tiftimeseries = header.frameTimestamps;

%% get photostim geometry
header.SI.hPhotostim.sequenceSelectedStimuli;
stimGroups; % defined in reference space
end
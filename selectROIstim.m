function roiStruct = selectROIstim(refImage,varargin)

%Select ROIs from a reference image, generate properties including
%centroids and x/y diameters both in pixel and in mirror command voltage
%units. Mirror command voltage assumes the image is 512x512 pixels, and
%that the scan amplitude is 20/3 (20 degrees at 3deg/volt). Scan amp can be
%overwritten as 3rd input, existing ROI structure can be entered as second
%argument

if nargin>2
    roiStruct = varargin{1};
    nROI = length(roiStruct);    
    scanAmp = varargin{2};
elseif nargin>1
    roiStruct = varargin{1};
    nROI = length(roiStruct);
    scanAmp = 20/3;
else
    roiStruct = {};
    nROI = 0;
    scanAmp = 20/3;
end

if nROI > 0
    for cROI=1:nROI
        refImage = refImage .* (1-roiStruct(cROI).mask);
    end
elseif nROI == 0
    cROI = 0;
end

satisfaction = 0; 
figure,imagesc(refImage),
while satisfaction == 0
    cROI = cROI + 1;
    hEll = imellipse;
    satisfaction = input('Stop Selecting ROIs? (-1 to cancel curent)');
    if isempty(satisfaction)
        satisfaction = 0;
    end
    if satisfaction~=-1
        roiStruct(cROI).mask = hEll.createMask;
        roiStruct(cROI).rect = hEll.getPosition;
        roiStruct(cROI).centroid = [roiStruct(cROI).rect(1) + roiStruct(cROI).rect(3)/2, ...
            roiStruct(cROI).rect(2) + roiStruct(cROI).rect(4)/2];
        roiStruct(cROI).axesDiameter = (roiStruct(cROI).rect(3:4) - 1)*(scanAmp/511);
        roiStruct(cROI).offset = (roiStruct(cROI).centroid-1)*(scanAmp/511)-(scanAmp/2);
        refImage = refImage .* (1-roiStruct(cROI).mask);
        delete(hEll),
        imagesc(refImage),
    end
end

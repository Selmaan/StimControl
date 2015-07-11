function obj = roiGenSemiautoManual(obj, desiredPoint, noGui)
  %% --- params handle
	if (nargin < 2)  
	  help('scanimage.mroi.gui.roi.roiArray.roiGenSemiautoDisk'); 
		error('scanimage.mroi.gui.roi.roiArray.roiGenSemiautoDisk::requires center coordinate.');
	end
	if (nargin < 3) ; noGui = 0; end

    desiredPoint = round(desiredPoint);

	%% --- the call to the detector ...
    imgWidth = max(obj.settings.semiAutoGrad.radiusRange);
    imgInds = -imgWidth:imgWidth;
    tempImg = obj.masterImage(desiredPoint(2)+imgInds,desiredPoint(1)+imgInds);
    borderXY = scRoiExtract(tempImg,imgWidth,desiredPoint);   
	
    %% Get other properties
    tRoi = scanimage.mroi.gui.roi.roi(-1, borderXY, [], [1 0 0.5], obj.imageBounds, []);
    tRoi.fillToBorder(obj.workingImageXMat, obj.workingImageYMat);
    borderXY = tRoi.computeBoundingPoly();
    tRoi.assignBorderIndices();
	borderIndices = tRoi.borderIndices;
	roiIndices = round(tRoi.indices);
    
	%% --- handle the returned stuff: create roi and select it
	if (numel(borderXY) > 0)
		% build new roi, generating corners from border ...
		tRoi = scanimage.mroi.gui.roi.roi(-1, borderXY, roiIndices, [1 0 0.5], obj.imageBounds, []);
        tRoi.borderIndices = borderIndices;
        
		% add it
		obj.addRoi(tRoi);

		% select it & update gui
		obj.guiSelectedRoiIds = tRoi.id;
    if (noGui == 0)
		  obj.updateImage();
    end
	end

end


%--------------------------------------------------------------------------%
% roiGenSemiautoManual.m                                                   %
% Copyright © 2015 Vidrio Technologies, LLC                                %
%                                                                          %
% ScanImage 2015 is premium software to be used under the purchased terms  %
% Code may be modified, but not redistributed without the permission       %
% of Vidrio Technologies, LLC                                              %
%--------------------------------------------------------------------------%

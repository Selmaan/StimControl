function xCorrRefs(iRefFile,nRefFile,resPockelsBorder,pix2um,SI4)

% iRefFile = 'E:\Data\Coexpression Tests\Scc7\14_07_14\FOV1_ROI1_001.tif';
% nRefFile = 'E:\Data\Coexpression Tests\Scc7\14_07_14\FOV1_ROI1_012.tif';
% resPockelsBorder = 50;
% pix2um = 1e3/512;

%Load movies and calculate reference images (can change to mean for speed)
[iMov,iMovProps] = tiffRead(iRefFile,'single');
[nMov,nMovProps] = tiffRead(nRefFile,'single');
display('Calculating Median Ref Images')
iRef = mean(iMov,3);
nRef = mean(nMov,3);
if resPockelsBorder>0
    iRef = iRef(:,resPockelsBorder:end-resPockelsBorder);
    nRef = nRef(:,resPockelsBorder:end-resPockelsBorder);
end

%Calculate Shift
[xPix,yPix] = track_subpixel_motion_fft(double(nRef),double(iRef));
display(sprintf('Calculated x shift of: %3.3f pixels \n Calculated y shift of: %3.3f pixels',xPix,yPix))

%Transform pixel shift to microns and update motor
zoomLvl = iMovProps.SI4.scanZoomFactor;
motorXYZum = [xPix,yPix,0] * pix2um/zoomLvl;
display(sprintf('Calculated x shift of: %3.3f microns \n Calculated y shift of: %3.3f microns',motorXYZum(1),motorXYZum(2)))

if max(motorXYZum)>10
    doBreak = input('Warning, large calculated shift, input 1 to cancel: ');
    if doBreak == 1
        return
    end
end

currentPos = SI4.motorPosition;
SI4.motorPosition = currentPos + motorXYZum;
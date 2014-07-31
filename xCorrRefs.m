function xCorrRefs(resPockelsBorder,hSI)

%If res, pix2um should be [x y] [1.8910 2.1034] and y shift is inverted
%In practice this conversion seems a bit variable, better to undershift
pix2um = [1.85 2 0];

%Load movies and calculate reference images (can change to mean for speed)
iRefFile = uigetfile([hSI.loggingFilePath '\*.tif'],'Choose Reference Image');
nRefFile = uigetfile([hSI.loggingFilePath '\*.tif'],'Choose Recent Image');
[iMov,iMovProps] = tiffRead(fullfile(hSI.loggingFilePath,iRefFile),'single');
[nMov,nMovProps] = tiffRead(fullfile(hSI.loggingFilePath,nRefFile),'single');
%display('Calculating Median Ref Images')
iRef = mean(iMov,3);
nRef = mean(nMov,3);
if resPockelsBorder>0
    iRef = iRef(:,resPockelsBorder:end-resPockelsBorder);
    nRef = nRef(:,resPockelsBorder:end-resPockelsBorder);
end

%Calculate Shift
[xPix,yPix] = track_subpixel_motion_fft(double(nRef),double(iRef));
%[xPix,yPix] = track_subpixel_wholeframe_motion_varythresh(double(iRef),double(nRef),25,.99,100);
%If image is res path, flip Y shift
yPix = -yPix;
display(sprintf('Calculated x shift of: %3.3f pixels \n Calculated y shift of: %3.3f pixels',xPix,yPix))

%Transform pixel shift to microns and update motor
zoomLvl = iMovProps.SI4.scanZoomFactor;
motorXYZum = [xPix,yPix,0].*pix2um/zoomLvl;
display(sprintf('Calculated x shift of: %3.3f microns \n Calculated y shift of: %3.3f microns',motorXYZum(1),motorXYZum(2)))

if max(motorXYZum)>10
    doBreak = input('Warning, large calculated shift, input 1 to cancel: ');
    if doBreak == 1
        return
    end
end

currentPos = hSI.motorPosition;
hSI.motorPosition = currentPos - motorXYZum;
function roiCentroids = roiPix2World(acqObj,RA)

ROIs = acqObj.roiInfo.slice.roi;
movSize = acqObj.correctedMovies.slice.channel.size(1,1:2);

for nROI = 1:length(ROIs)
    [i,j] = ind2sub(movSize,ROIs(nROI).indBody);
    [xWorld,yWorld] = intrinsicToWorld(RA,j,i);
    roiCentroids(nROI,:) = [median(xWorld) median(yWorld)];
end
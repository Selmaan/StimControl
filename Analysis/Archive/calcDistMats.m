function stimExpt = calcDistMats(stimExpt)

roiCentroid = stimExpt.roiCentroid;
nROIs = size(roiCentroid,1);
normDistX = repmat(roiCentroid(:,1),1,nROIs)-...
    repmat(roiCentroid(:,1)',nROIs,1);
normDistY = repmat(roiCentroid(:,2),1,nROIs)-...
    repmat(roiCentroid(:,2)',nROIs,1);

stimExpt.distMat = sqrt((stimExpt.xConvFactor*normDistX).^2 +...
    (stimExpt.yConvFactor*normDistY).^2);


acqCentroids = roiPix2World(stimExpt.acq,stimExpt.resRA);
nROIs = size(acqCentroids,1);
acqDistX = repmat(acqCentroids(:,1),1,nROIs)-...
    repmat(acqCentroids(:,1)',nROIs,1);
acqDistY = repmat(acqCentroids(:,2),1,nROIs)-...
    repmat(acqCentroids(:,2)',nROIs,1);

stimExpt.acqDistMat = sqrt((stimExpt.xConvFactor*acqDistX).^2 +...
    (stimExpt.yConvFactor*acqDistY).^2)';

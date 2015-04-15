deStim = nan(size(de,1),size(de,1),max(tV.nRepeat),600);
distMat = nan(size(dF,1));
for nTarg = 1:size(dF,1)
    sel = tV.nTarg == nTarg;
    for nROI = 1:size(dF,1)
        deStim(nTarg,nROI,:,:) = getTrigStim(de,tV,sel,nROI,0,0);
        distMat(nTarg,nROI) = norm(stimExpt.StimROIs.roi(nROI).elCentroid - ...
            stimExpt.StimROIs.roi(nTarg).elCentroid);
    end
end

pkStim = sum(deStim(:,:,:,300:315),4);

for rep=1:size(pkStim,3)
    repStim(:,rep) = diag(pkStim(:,:,rep));
end
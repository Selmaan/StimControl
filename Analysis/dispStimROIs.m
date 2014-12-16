function hEl = dispStimROIs(StimROIs)

figure,imshow(StimROIs.ref)

nROIs = length(StimROIs.roi);

for nROI = 1:nROIs
    elPos(1:2) = StimROIs.roi(nROI).elCentroid - StimROIs.roi(nROI).elRadius;
    elPos(3:4) = 2 * StimROIs.roi(nROI).elRadius;
    hEl(nROI) = imellipse(gca,elPos);
end

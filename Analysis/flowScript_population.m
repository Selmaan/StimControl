pkStim = nan(size(de,1),size(de,1),length(tV.nTarg)/max(tV.nTarg));
distMat = nan(size(dF,1));

for nTarg = 1:size(dF,1)
    sel = tV.nTarg == nTarg;
    stimOnsets = cellfun(@min, tV.stimFrames(sel));
    for stimTrial = 1:length(stimOnsets)
        stimOnset = stimOnsets(stimTrial);
        pkStim(nTarg,:,stimTrial) = sum(de(:,stimOnset:stimOnset+10),2);
    end
    for nROI = 1:size(dF,1)
        distMat(nTarg,nROI) = norm(roiCentroid(nROI,:)-roiCentroid(nTarg,:));
    end
end


% for nTarg = 1:size(dF,1)
%     sel = tV.nTarg == nTarg;
%     for nROI = 1:size(dF,1)
%         deStim(nTarg,nROI,:,:) = getTrigStim(de,tV,sel,nROI,0,0);
%         distMat(nTarg,nROI) = norm(roiCentroid(nROI,:)-roiCentroid(nTarg,:));
%     end
% end
% 
% pkStim = sum(deStim(:,:,:,300:310),4);

for rep=1:size(pkStim,3)
    repStim(:,rep) = diag(pkStim(:,:,rep));
end
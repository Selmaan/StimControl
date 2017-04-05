pkStim = nan(size(roiCentroid,1),size(de,1),length(tV.nTarg)/max(tV.nTarg));
distMat = nan(size(dF,1));

for nROI = 1:size(dF,1)
    [indR,indC] = ind2sub([512 512],roi(nROI).indBody);
    estCentroid(nROI,:) = [mean(indC),mean(indR)];
end
xPixModel = robustfit(estCentroid(1:size(roiCentroid,1),1),roiCentroid(:,1));
yPixModel = robustfit(estCentroid(1:size(roiCentroid,1),2),roiCentroid(:,2));


for nTarg = 1:size(dF,1)
    if nTarg <= size(roiCentroid,1)
        sel = tV.nTarg == nTarg;
        stimOnsets = cellfun(@min, tV.stimFrames(sel));
        stimOffsets = cellfun(@max, tV.stimFrames(sel));
        for stimTrial = 1:length(stimOnsets)
            stimOnset = stimOnsets(stimTrial);
            stimOffset = stimOffsets(stimTrial);
            pkStim(nTarg,:,stimTrial) = sum(de(:,stimOnset:stimOffset+5),2);
        end
        targCentroid = roiCentroid(nTarg,:);
    else
        estXum = estCentroid(nTarg,1)*xPixModel(2) + xPixModel(1);
        estYum = estCentroid(nTarg,2)*yPixModel(2) + yPixModel(1);
        targCentroid = [estXum,estYum];
    end
    for nROI = 1:size(dF,1)
        if nROI <= size(roiCentroid,1)
            distMat(nTarg,nROI) = norm(roiCentroid(nROI,:)-targCentroid);
        else
            estXum = estCentroid(nROI,1)*xPixModel(2) + xPixModel(1);
            estYum = estCentroid(nROI,2)*yPixModel(2) + yPixModel(1);
            distMat(nTarg,nROI) = norm([estXum,estYum]-targCentroid);
        end
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
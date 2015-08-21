stimCells = find(stimMag>spkThresh);
respCells = find([roi.group]==1);
stimRepeats = size(repStim,2);
shufMat=[];
ctrlMat=[];
for iROI = 1:length(respCells)
    nROI = respCells(iROI),
    validTargets = find(distMat(nROI,:)>=distThresh);
    sel = ismember(tV.nTarg,validTargets);
    validForShuf = tV.stimFrames(sel);
    shufResp = nan(nShuffles,1);
    for nShuffle = 1:nShuffles
        thisShuf = randperm(length(validForShuf),stimRepeats);
        stimOnsets = cellfun(@min, validForShuf(thisShuf));
        respFrames = repmat(stimOnsets,11,1) + repmat((0:10)',1,stimRepeats);
        shufResp(nShuffle) = sum(de(nROI,respFrames(:)))/stimRepeats;
    end

    shufBelow = [];
    ctrlBelow = [];
    for i=1:length(stimCells)
        shufBelow(i) = sum(respMat(stimCells(i),nROI)>=shufResp);
        ctrlBelow(i) = sum(shufResp(randperm(nShuffles,1))>=shufResp);
    end
    shufMat(:,iROI) = shufBelow;
    ctrlMat(:,iROI) = ctrlBelow;
end

shufOdds = nShuffles./(nShuffles+1-shufMat);
ctrlOdds = nShuffles./(nShuffles+1-ctrlMat);
shufDist = distMat(stimCells,respCells);
shufVals = shufOdds(shufDist>=distThresh);
ctrlVals = ctrlOdds(shufDist>=distThresh);
figure,ecdf(log10(ctrlVals))
hold on,ecdf(log10(shufVals)),
xlabel('log inverse FP Odds')
figure,plot(shufDist(shufDist>=distThresh),log10(shufVals),'.')
title('True Values'),
ylabel('log inverse FP Odds')
xlabel('Interaction Distance')
ylim([-0.1 5.1])
figure,plot(shufDist(shufDist>=distThresh),log10(ctrlVals),'.')
title('Shuffled Values'),
ylabel('log inverse FP Odds')
xlabel('Interaction Distance')
ylim([-0.1 5.1])
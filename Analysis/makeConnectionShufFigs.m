stimRepeats = size(repStim,2);
stimFrameOffsets = repmat((0:stimTotalDur-1)',1,stimRepeats);
shufMat=[];
ctrlMat=[];
for iROI = 1:length(respCells)
    nROI = respCells(iROI),
    validTargets = find(distMat(nROI,:)>=distThresh);
    sel = ismember(tV.nTarg,validTargets);
    validForShuf = tV.stimFrames(sel);
    validForShuf = [validForShuf{:}];
    validOnsets = validForShuf(1,:);
    shufResp = nan(nShuffles,1);
    for nShuffle = 1:nShuffles
        thisShuf = randperm(length(validOnsets),stimRepeats);
        stimOnsets = validOnsets(thisShuf);
%         stimOnsets = cellfun(@min, validForShuf(thisShuf));
        respFrames = repmat(stimOnsets,stimTotalDur,1) + stimFrameOffsets;
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
figure,plot(shufDist(shufDist>=distThresh),log10(shufVals),'.')
title('True Values'),
ylabel('log inverse FP Odds')
xlabel('Interaction Distance')
ylim([-0.1 log10(nShuffles)+0.1])
figure,plot(shufDist(shufDist>=distThresh),log10(ctrlVals),'.')
title('Shuffled Values'),
ylabel('log inverse FP Odds')
xlabel('Interaction Distance')
ylim([-0.1 log10(nShuffles)+0.1])
[fC,xC]=ecdf(log10(ctrlVals));
[fT,xT]=ecdf(log10(shufVals));
figure
semilogy(log10(1:nShuffles/100:nShuffles/10),1./(1:nShuffles/100:nShuffles/10),'k')
hold on
semilogy(xC,1-fC,'linewidth',3)
semilogy(xT,1-fT,'linewidth',3)
xlabel('log10 inverse FP Odds')
ylabel('Fraction Measurements Positive')
legend('Theory','Control','Data')
winRad = 30;
winDiam = 2*winRad+1;
stimIm = zeros(winDiam,winDiam);
[yInd,xInd] = stimExpt.resRA.worldToSubscript(stimExpt.cellCentroids(:,1),stimExpt.cellCentroids(:,2));
yInd = yInd+winRad; xInd = xInd+winRad;
distBin = tmp.Dist<100 & tmp.Dist<1e3 & tmp.naiveCorr<0;

for nStim = 1:50
    thisStimIm = padarray(stimExpt.rawStimIm(:,:,nStim),[winRad winRad],0);
    for nResp = 1:300
        if distBin(nResp,nStim) && ~isnan(validResp(nResp,nStim))
            xRange = xInd(nResp)-winRad:xInd(nResp)+winRad;
            yRange = yInd(nResp)-winRad:yInd(nResp)+winRad;
            thisIm = thisStimIm(yRange,xRange);
            thisIm(isnan(thisIm)) = 0;
            stimIm = stimIm + thisIm/mad(thisIm(:));
        end
    end
end

stimIm = stimIm / sum(~isnan(validResp(distBin)));
figure,imagesc(stimIm),
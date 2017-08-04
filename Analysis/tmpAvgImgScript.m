winRad = 25;
winDiam = 2*winRad+1;
stimIm = zeros(winDiam,winDiam);
[yInd,xInd] = stimExpt.resRA.worldToSubscript(stimExpt.cellCentroids(:,1),stimExpt.cellCentroids(:,2));
yInd = yInd+winRad; xInd = xInd+winRad;
distBin = tmp.Dist<1e3 & tmp.Dist>-1 & (tmp.betaBin > median(tmp.betaBin));
refIm = bsxfun(@rdivide,stimExpt.rawStimIm,meanRef(resFOV1));

for nStim = 1:size(validResp,2)
    thisStimIm = padarray(refIm(:,:,nStim),[winRad winRad],0);
    for nResp = 1:size(validResp,1)
        if distBin(nResp,nStim) && ~isnan(validResp(nResp,nStim))
            xRange = xInd(nResp)-winRad:xInd(nResp)+winRad;
            yRange = yInd(nResp)-winRad:yInd(nResp)+winRad;
            thisIm = thisStimIm(yRange,xRange);
            thisIm(isnan(thisIm)) = 0;
%             stimIm = stimIm + thisIm/mad(thisIm(:));
            stimIm = stimIm + thisIm;
        end
    end
end

stimIm = stimIm / sum(~isnan(validResp(distBin)));
figure,imagesc(stimIm),colorbar,
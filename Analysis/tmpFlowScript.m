
%%

if ~isfield(stimExpt,'ballVel')
    for nBlock = 1:length(stimExpt.syncFns)
        syncDat = abfload(stimExpt.syncFns{nBlock});
        tmp = medfilt1(syncDat(:,3:5),100) - 1.5135;
        stimExpt.ballVel{nBlock} = tmp(stimExpt.frameTimes{nBlock},:);
        clear tmp
    end
    cd(fileparts(stimExpt.syncFns{1})),
    warning('Saving updated stimExpt w ball Velocity'),
    save('stimExpt','stimExpt'),
else
    fprintf('Ball Velocity is Already Calculated \n'),
end

%%

distThresh = 30;
[nRespMat, pRespMat, visResid, deResp, stimID, visOri, visCon, stimMag, mvSpd] =...
    calcStimShuffle(stimExpt, distThresh);
figure,plot(median(stimMag)),

[stimBeta,stimBetaVar,respBeta,respBetaVar,deResp,preResp,stimID,visOri,visCon,mvSpd] = ... 
    influenceRegression(stimExpt, distThresh);
figure,imagesc(corrcoef(respBeta./respBetaVar)),
%%
tmp.dBinWidth = 80;
validResp = stimBeta./stimBetaVar;
% validResp = nRespMat;
validResp(:,stimExpt.targetLabel==0)=nan;
tmp.Dist = stimExpt.cellStimDistMat*stimExpt.xConvFactor;
infDistBin = nan(500,1);
for d=1:500
    tmp.thesePairs = tmp.Dist<d+tmp.dBinWidth & tmp.Dist>d & ~isnan(validResp);
    tmp.theseVals = validResp(tmp.thesePairs);
%     infDistBin(d) = nanmean(tmp.theseVals);
    tmp.theseVar = stimBetaVar(tmp.thesePairs);
    infDistBin(d) = sum(tmp.theseVals)/sum(1./tmp.theseVar);
%     infDistBin(d) = trimmean(tmp.theseVals,0);
end
figure,plot((1:500)+tmp.dBinWidth/2,infDistBin),
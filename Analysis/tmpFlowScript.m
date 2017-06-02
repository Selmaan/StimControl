
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
tmp.dBinWidth = 100;
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
end
figure,plot((1:500)+tmp.dBinWidth/2,infDistBin),

%%
validResp = ~isnan(stimBeta);
% validResp = true(size(stimBeta)); 
% validResp(:,stimExpt.targetLabel<1)=false;
% Y = stimBeta(validResp)./sqrt(stimBetaVar(validResp));
dummyResp = repmat((1:size(validResp,1))',1,size(validResp,2));
dummyTarg = repmat(1:size(validResp,2),size(validResp,1),1);

X = stimExpt.cellStimDistMat(validResp)*stimExpt.xConvFactor;
distCenters = 0:50:600;
distWidth = 200;
[X,k] = cosineKernelize(X, distCenters, distWidth);
Z{1} = ones(sum(validResp(:)),1);
Z{2} = ones(sum(validResp(:)),1);
G{1} = dummyResp(validResp);
G{2} = dummyTarg(validResp);
lme = fitlmematrix(X,Y,Z,G),
rE = randomEffects(lme);
fE = fixedEffects(lme);
figure,plot(linspace(distCenters(1),distCenters(end),1e3),k*fE),
xlim([50 500]),
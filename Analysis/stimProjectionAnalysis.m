function [] = ... 
    stimProjectionAnalysis(stimExpt, distThresh)
%% Inputs
if nargin<2
    distThresh = 30;
end

respFrameRange1 = 1:10;
respFrameRange2 = 11:20;
preFrameRange = -6:-1;

distConv = stimExpt.xConvFactor;
if distConv ~= stimExpt.yConvFactor
    warning('x and y conversion factors are not equal!'),
end

%% Reformat Stim+Grating Response Data
visOri = [];visCon=[];stimID=[];mvSpd=[];mvPre=[];deResp=[];deResp2=[];preResp=[];
ballVel = cat(1,stimExpt.ballVel{:});
ballVel = bsxfun(@minus,ballVel,mode(ballVel));

for nBlock = find(stimExpt.stimBlocks)
    blockOffsetFrame = length(cat(1,stimExpt.frameTimes{1:nBlock-1}));
    lastTrial = find(~isnan(stimExpt.psych2frame{nBlock}),1,'last')-1;
    visFrames = stimExpt.psych2frame{nBlock}(1:lastTrial) + blockOffsetFrame;
    thisVisOri = stimExpt.stimInfo{nBlock}((1:3:lastTrial*3)+4); %stimSynch grating angle
    thisVisCon = stimExpt.stimInfo{nBlock}((2:3:lastTrial*3)+4); %stimSynch Contrast
    thisStimID = stimExpt.stimOrder{nBlock}';
    thisStimID(end+1:length(thisVisOri)) = nan;
    
    respFrames = bsxfun(@plus,visFrames,respFrameRange1)';
    thisMvSpd = reshape(ballVel(respFrames,:),[size(respFrames), size(ballVel,2)]);
    thisMvSpd = sqrt(sum(squeeze(mean(thisMvSpd,1)).^2,2));
    thisDeResp = reshape(stimExpt.dF_deconv(:,respFrames),...
           [size(stimExpt.dF_deconv,1),size(respFrames)]);
    thisDeResp = squeeze(mean(thisDeResp,2))';
    
    respFrames2 = bsxfun(@plus,visFrames,respFrameRange2)';
    thisDeResp2 = reshape(stimExpt.dF_deconv(:,respFrames2),...
           [size(stimExpt.dF_deconv,1),size(respFrames2)]);
    thisDeResp2 = squeeze(mean(thisDeResp2,2))';
    
    preFrames = bsxfun(@plus,visFrames,preFrameRange)';
    thisPreResp = reshape(stimExpt.dF_deconv(:,preFrames),...
           [size(stimExpt.dF_deconv,1),size(preFrames)]);
    thisPreResp = squeeze(mean(thisPreResp,2))';
    thisPreMvSpd = reshape(ballVel(preFrames,:),[size(preFrames), size(ballVel,2)]);
    thisPreMvSpd = sqrt(sum(squeeze(mean(thisPreMvSpd,1)).^2,2));
    
    visOri = cat(1,visOri,thisVisOri);
    visCon = cat(1,visCon,thisVisCon);
    stimID = cat(1,stimID,thisStimID);
    mvSpd = cat(1,mvSpd,thisMvSpd);
    mvPre = cat(1,mvPre,thisPreMvSpd);
    deResp = cat(1,deResp,thisDeResp);
    deResp2 = cat(1,deResp2,thisDeResp2);
    preResp = cat(1,preResp,thisPreResp);
end

%% Get Average Vectors and Residuals

allDirs = unique(visOri);
visAvg = nan(size(deResp,2),length(allDirs)); 
visResid = nan(size(deResp));
visAvg2 = nan(size(deResp,2),length(allDirs));
visResid2 = nan(size(deResp2));
subResp1 = (deResp-preResp)./std(preResp);
subResp2 = (deResp2-preResp)./std(preResp);

for i=1:length(allDirs)
    theseTrials = visOri==allDirs(i);
    for n=1:size(stimExpt.cellStimDistMat,1)
        invalidStim = find(stimExpt.cellStimDistMat(n,:)...
            *distConv < distThresh);
        validInd = theseTrials & ~ismember(stimID,invalidStim);
        invalidInd = theseTrials & ismember(stimID,invalidStim);
        visAvg(n,i) = mean(subResp1(validInd,n));
        visAvg2(n,i) = mean(subResp2(validInd,n));
        visResid(validInd,n) = subResp1(validInd,n)-visAvg(n,i);
        visResid(invalidInd,n) = 0;
        visResid2(validInd,n) = subResp2(validInd,n)-visAvg2(n,i);
        visResid2(invalidInd,n) = 0;
    end
end

%% Get Projections

visNorm1 = visAvg./sqrt(sum(visAvg.^2));
visNorm2 = visAvg2./sqrt(sum(visAvg2.^2));

onResid1 = nan(length(visOri),1);
allResid1 = nan(length(visOri),length(allDirs));
gainProj1 = nan(length(visOri),length(allDirs));
onResid2 = nan(length(visOri),1);
allResid2 = nan(length(visOri),length(allDirs));
gainProj2 = nan(length(visOri),length(allDirs));

for nTrial=1:length(visOri)
    thisOriInd = find(visOri(nTrial)==allDirs);
    
    thisProj1 = visNorm1(:,thisOriInd);
    onResid1(nTrial) = visResid(nTrial,:) * thisProj1;
    allResid1(nTrial,:) = visResid(nTrial,:) * circshift(visNorm1,-thisOriInd,2);
    gainProj1(nTrial,:) = (onResid1(nTrial)*thisProj1') * circshift(visNorm1,-thisOriInd,2);

    thisProj2 = visNorm2(:,thisOriInd);
    onResid2(nTrial) = visResid2(nTrial,:) * thisProj2;
    allResid2(nTrial,:) = visResid2(nTrial,:) * circshift(visNorm2,-thisOriInd,2);
    gainProj2(nTrial,:) = (onResid2(nTrial)*thisProj2') * circshift(visNorm2,-thisOriInd,2);
end
uniNorm = ones(size(visResid,2),1)/sqrt(size(visResid,2));
uniProj = visResid * uniNorm;

stimTrials = ismember(stimID,find(stimExpt.targetLabel==1));
controlTrials = ismember(stimID,find(stimExpt.targetLabel==0));
gainMod = mean(gainProj1(stimTrials,:))' - mean(gainProj1(controlTrials,:))';
trueMod = mean(allResid1(stimTrials,:))' - mean(allResid1(controlTrials,:))';
uniMod = mean(uniProj(stimTrials))-mean(uniProj(controlTrials));
trueStd = std(allResid1)';
uniStd = std(uniProj);
figure,bar([gainMod,trueMod]),line([0 9],[uniMod uniMod],'color','k','linestyle','--'),
figure,bar([gainMod,trueMod]./trueStd),line([0 9],[uniMod uniMod]/uniStd,'color','k','linestyle','--'),


%% shuffles?
stimTrials = ismember(stimID,find(stimExpt.targetLabel==1));
controlTrials = ismember(stimID,find(stimExpt.targetLabel==0));


onOri = sum(allResid1(:,[4,8]),2);
offOri = sum(allResid1(:,[1:3,5:7]),2);
offGain = sum(gainProj1(:,[1:3,5:7]),2);

%%
nShuffles = 1e4;
shufMod = nan(nShuffles,1);

for nShuffle = 1:nShuffles
    stimID_permuted = circshift(stimID,randi(length(stimID)));
    stimTrials_permuted = ismember(stimID_permuted,find(stimExpt.targetLabel==1));
    controlTrials_permuted = ismember(stimID_permuted,find(stimExpt.targetLabel==0));
    
    shufMod(nShuffle) = mean(onOri(stimTrials_permuted))-mean(onOri(controlTrials_permuted));
end

trueMod = mean(onOri(stimTrials))-mean(onOri(controlTrials)),
mean(trueMod<shufMod)


%%
nShuffles = 1e4;
shufMod = nan(nShuffles,1);

for nShuffle = 1:nShuffles
    stimID_permuted = circshift(stimID,randi(length(stimID)));
    stimTrials_permuted = ismember(stimID_permuted,find(stimExpt.targetLabel==1));
    controlTrials_permuted = ismember(stimID_permuted,find(stimExpt.targetLabel==0));
    
    shufMod(nShuffle) = mean(offOri(stimTrials_permuted)-offGain(stimTrials_permuted))-...
        mean(offOri(controlTrials_permuted)-offGain(controlTrials_permuted));
end

trueMod = mean(offOri(stimTrials)-offGain(stimTrials))-...
    mean(offOri(controlTrials)-offGain(controlTrials)),
mean(trueMod<shufMod)
function [stimBeta,stimBetaVar,respBeta,respBetaVar,contBeta,contBetaVar,deResp,preResp,stimID,visOri,visCon,mvSpd] = ... 
    influenceRegression(stimExpt, distThresh)
%% Inputs
if nargin<2
    distThresh = 30;
end

respFrameRange = 0:15;
preFrameRange = -6:-1;

distConv = stimExpt.xConvFactor;
if distConv ~= stimExpt.yConvFactor
    warning('x and y conversion factors are not equal!'),
end

%% Reformat Stim+Grating Response Data
visOri = [];visCon=[];stimID=[];mvSpd=[];mvPre=[];deResp=[];preResp=[];
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
    
    respFrames = bsxfun(@plus,visFrames,respFrameRange)';
    thisMvSpd = reshape(ballVel(respFrames,:),[size(respFrames), size(ballVel,2)]);
    thisMvSpd = sqrt(sum(squeeze(mean(thisMvSpd,1)).^2,2));
    thisDeResp = reshape(stimExpt.dF_deconv(:,respFrames),...
           [size(stimExpt.dF_deconv,1),size(respFrames)]);
    thisDeResp = squeeze(mean(thisDeResp,2))';
    
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
    preResp = cat(1,preResp,thisPreResp);
end

%% Make Predictor Matrix

validStim = find(stimExpt.targetLabel>0);
controlStim = find(stimExpt.targetLabel==0);
if isempty(controlStim)
    error('No Control Stimulation Targets Found'),
end
nStim = length(validStim);

tmpDist = stimExpt.cellStimDistMat*distConv;
invalidTargets = false(size(deResp,2),nStim);
validTrials = false(size(deResp));
for n = 1:size(deResp,2)
    invalidStim = find(tmpDist(n,:) < distThresh);
    validTrials(:,n) = ~ismember(stimID,invalidStim) & ~isnan(stimID);
    if ~isempty(invalidStim)
        for i=1:length(invalidStim)
            if ismember(invalidStim(i),validStim)
                invalidTargets(n,invalidStim(i)==validStim) = true;
            end
        end
    end
end

allDir = unique(visOri);
if length(unique(visCon))>1
    error('UPDATE FUNCTION FOR MULTIPLE CONTRASTS!'),
end

X = zeros(size(deResp,1),nStim+length(allDir));
for iStim = 1:nStim
    X(:,iStim) = (stimID == validStim(iStim));
%     X(:,iStim) = (stimID == iStim);
end
% X(sum(X(:,1:nStim),2)==0,nStim+1) = 1;

for iDir = 1:length(allDir)
    X(:,nStim+iDir) = (visOri == allDir(iDir));
end
X(:,nStim+length(allDir)+1) = mvSpd;
X(:,nStim+length(allDir)+2) = mvSpd>5*mode(mvSpd);

X2 = zeros(size(X));
X2(:,end-1) = mvPre;
X2(:,end) = mvPre>5*mode(mvPre);

%% Fit diffuse BLMs
validColumns = cell(0);
fitMu = nan(size(deResp,2),size(X,2)+1);
fitVar = nan(size(deResp,2),size(X,2)+1);
contMu = nan(size(deResp,2), size(X,2)+1-nStim);
contVar = nan(size(deResp,2), size(X,2)+1-nStim);
for n=1:size(deResp,2)
    tri = validTrials(:,n);
    excludeTarg = find(invalidTargets(n,:));
    validColumns{n} = setdiff(1:size(X,2),excludeTarg);
    thisX = cat(1,X(tri,validColumns{n}),X2(tri,validColumns{n}));
    thisY = cat(1,deResp(tri,n),preResp(tri,n));
    [~,tmpMu,tmpCov] = estimate(diffuseblm(size(thisX,2)),thisX,thisY,'Display',false);
    tmpVar = diag(tmpCov);
    fitMu(n,[1,1+validColumns{n}]) = tmpMu;
    fitVar(n,[1,1+validColumns{n}]) = tmpVar;
    
    controlTrials = sum(X(:,1:nStim),2)==0;
    controlX = cat(1,X(controlTrials,nStim+1:end),X2(controlTrials,nStim+1:end));
    controlY = cat(1,deResp(controlTrials,n),preResp(controlTrials,n));
    [~,tmpMu,tmpCov] = estimate(diffuseblm(size(controlX,2)),controlX,controlY,'Display',false);
    tmpVar = diag(tmpCov);
    contMu(n,:) = tmpMu;
    contVar(n,:) = tmpVar;
end

%% Reformat Fitted parameters
stimBeta = nan(size(deResp,2),length(stimExpt.targetLabel));
stimBetaVar = nan(size(deResp,2),length(stimExpt.targetLabel));
stimBeta(:,validStim) = fitMu(:,2:nStim+1);
stimBetaVar(:,validStim) = fitVar(:,2:nStim+1);

respBeta = fitMu(:,[1, nStim+2:size(fitMu,2)]);
respBetaVar = fitVar(:,[1, nStim+2:size(fitMu,2)]);
contBeta = contMu;
contBetaVar = contVar;

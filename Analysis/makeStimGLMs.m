function [coefs,fits,deResp,stimID,visOri,visCon] = ... 
    makeStimGLMs(stimExpt, distThresh)

if nargin<2
    distThresh = 25;
end
distConv = stimExpt.xConvFactor;

respFrameRange = 0:10;
nFolds = 50;

%% TEMPORARY FIX FOR BASELINE ERROR!!
for n = find(sum(stimExpt.dF_deconv<0,2)>0)
    stimExpt.dF_deconv(n,:) = stimExpt.dF_deconv(n,:)*-1;
end

%% Reformat Stim+Grating Response Data
visOri = [];visCon=[];stimID=[];deResp=[];
for nBlock = find(stimExpt.stimBlocks)
    blockOffsetFrame = length(cat(1,stimExpt.frameTimes{1:nBlock-1}));
    lastTrial = find(~isnan(stimExpt.psych2frame{nBlock}),1,'last')-1;
    visFrames = stimExpt.psych2frame{nBlock}(1:lastTrial) + blockOffsetFrame;
    thisVisOri = stimExpt.stimInfo{nBlock}((1:3:lastTrial*3)+4); %stimSynch grating angle
    thisVisCon = stimExpt.stimInfo{nBlock}((2:3:lastTrial*3)+4); %stimSynch Contrast
    thisStimID = stimExpt.stimOrder{nBlock}';
    thisStimID(end+1:length(thisVisOri)) = nan;
    respFrames = bsxfun(@plus,visFrames,respFrameRange)';
    thisDeResp = reshape(stimExpt.dF_deconv(:,respFrames),...
           [size(stimExpt.dF_deconv,1),size(respFrames)]);
    thisDeResp = squeeze(mean(thisDeResp,2))';
    
    visOri = cat(1,visOri,thisVisOri);
    visCon = cat(1,visCon,thisVisCon);
    stimID = cat(1,stimID,thisStimID);
    deResp = cat(1,deResp,thisDeResp);
end

%% Make Predictor Matrix

nStim = max(stimID);
allDir = unique(visOri);
if length(unique(visCon))>1
    error('UPDATE FUNCTION FOR MULTIPLE CONTRASTS!'),
end
X = zeros(size(deResp,1),nStim+length(allDir)+1);
for iStim = 1:nStim
    X(:,iStim) = (stimID == iStim);
end
X(sum(X(:,1:nStim),2)==0,nStim+1) = 1;
for iDir = 1:length(allDir)
    X(:,1+nStim+iDir) = (visOri == allDir(iDir));
end

tmpDist = stimExpt.cellStimDistMat*distConv;
validTrialsCell = cell(0);
for n = 1:size(deResp,2)
    invalidStim = find(tmpDist(n,:) < distThresh);
%     validTrialsCell{n} = find(~ismember(stimID,invalidStim) & ~isnan(stimID));
    validTrialsCell{n} = find(~ismember(stimID,invalidStim));
end

%% fit GLMs

opt = glmnetSet;
opt.alpha = 0;%1/2;
opt.thresh = 1e-6;
opt.nlambda = 50;
opt.lambda_min = 1e-3;

fits = cvglmnet(X(validTrialsCell{1},:),deResp(validTrialsCell{1},1),'poisson',opt,[],nFolds);
for nSig = 2:size(deResp,2)
    nSig,
    theseTrials = validTrialsCell{nSig};
    y = deResp(theseTrials,nSig);
    if sum(y)>1e-2
        fits(nSig) = cvglmnet(X(theseTrials,:),y,'poisson',opt,[],nFolds,[],true);
    else
        fprintf('Skipping Neuron %d \n',nSig),
    end
end

%% Extract Coefficients
for nSig = 1:length(fits)
    if ~isempty(fits(nSig).lambda)
        thisInd = find(fits(nSig).lambda==fits(nSig).lambda_min);
        coefs(nSig,:) = fits(nSig).glmnet_fit.beta(:,thisInd)';
    end
end

coefs(tmpDist < distThresh) = nan;

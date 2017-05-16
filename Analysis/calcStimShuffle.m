function [nRespMat, pRespMat, visResid, deResp, stimID, visOri, visCon, stimMag, mvSpd] = ...
    calcStimShuffle(stimExpt, distThresh)

if nargin<2
    distThresh = 30;
end

respFrameRange = 0:15;
distConv = stimExpt.xConvFactor;
if distConv ~= stimExpt.yConvFactor
    warning('x and y conversion factors are not equal!'),
end

nShuffles = 1e4;


%% Reformat Stim+Grating Response Data
visOri = [];visCon=[];stimID=[];deResp=[];mvSpd=[];
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
    thisDeResp = reshape(stimExpt.dF_deconv(:,respFrames),...
           [size(stimExpt.dF_deconv,1),size(respFrames)]);
    thisDeResp = squeeze(mean(thisDeResp,2))';
    thisMvSpd = reshape(ballVel(respFrames,:),[size(respFrames), size(ballVel,2)]);
    thisMvSpd = sqrt(sum(squeeze(mean(thisMvSpd,1)).^2,2));
    
    visOri = cat(1,visOri,thisVisOri);
    visCon = cat(1,visCon,thisVisCon);
    stimID = cat(1,stimID,thisStimID);
    deResp = cat(1,deResp,thisDeResp);
    mvSpd = cat(1,mvSpd,thisMvSpd);
end

%% Calculate Residual Signal
allDirs = unique(visOri);
allCon = unique(visCon);
visAvg = []; visResid = [];
for s=1:length(allDirs)
    for c=1:length(allCon)
        theseTrials = visOri==allDirs(s) & visCon==allCon(c);
        for n=1:size(stimExpt.cellStimDistMat,1)
            invalidStim = find(stimExpt.cellStimDistMat(n,:)...
                *distConv < distThresh);
            validInd = find(theseTrials & ~ismember(stimID,invalidStim));
            visAvg(s,c,n) = mean(deResp(validInd,n));
        end
        visResid(theseTrials,:) = bsxfun(@minus,deResp(theseTrials,:),squeeze(visAvg(s,c,:))');
    end
end

validTargets = find(stimExpt.targetLabel>=1);
for i=1:length(validTargets)
    theseTrials = find(stimID == validTargets(i));
    stimMag(i,:) = visResid(theseTrials,i);
end

%% Shuffle Bootstrap

nRespCells = size(visResid,2);
nTargets = length(stimExpt.stimSources);
nReps = sum(~isnan(stimID))/nTargets;
fprintf('Detected Repetitions of Target Stim: %d \n',nReps),
nTrials = size(visResid,1);

tmpDist = stimExpt.cellStimDistMat*distConv;
validTrialsCell = cell(0);
for n = 1:nRespCells
    invalidStim = find(tmpDist(n,:) < distThresh);
    validTrialsCell{n} = find(~ismember(stimID,invalidStim));
end

shufMat = nan(nShuffles,nRespCells);
parfor n=1:nRespCells
    validTrials = validTrialsCell{n};
    nValid = length(validTrials);
    for nShuffle = 1:nShuffles
        subTri = validTrials(randperm(nValid,nReps));
        shufMat(nShuffle,n) = mean(visResid(subTri,n));
    end
end

shufMAD = mean(abs(shufMat));

respMat = nan(nRespCells,nTargets);
for nStimCell = 1:nTargets
    theseTri = find(stimID==nStimCell);
    validCells = find(stimExpt.cellStimDistMat(:,nStimCell)*distConv >= distThresh);
    respMat(validCells,nStimCell) = mean(visResid(theseTri,validCells))';
end
pRespMat = bsxfun(@rdivide,respMat,shufMAD' * 1.253);

for n=1:size(respMat,1)
    for t=1:size(respMat,2)
        gtMat(n,t) = sum(shufMat(:,n)>respMat(n,t));
        ltMat(n,t) = sum(shufMat(:,n)<respMat(n,t));
    end
end

nRespMat = log10((nShuffles-gtMat+1)./(nShuffles-ltMat+1));
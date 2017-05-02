function [nRespMat, visResid, deResp, stimID, visOri, visCon, stimMag] = ...
    calcStimShuffle(stimExpt, distThresh)

if nargin<2
    distThresh = 30;
end

respFrameRange = 0:10;
distConv = stimExpt.xConvFactor;
nShuffles = 1e3;

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

for i=1:length(stimExpt.cellStimInd)
    theseTrials = find(stimID == i);
    stimMag(i) = mean(visResid(theseTrials,stimExpt.cellStimInd(i)));
end

%% Shuffle Bootstrap

nRespCells = size(visResid,2);
nStimCells = length(stimExpt.cellStimInd);
nReps = sum(~isnan(stimID))/nStimCells;
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

respMat = nan(nRespCells,nStimCells);
for nStimCell = 1:nStimCells
    theseTri = find(stimID==nStimCell);
    validCells = find(stimExpt.cellStimDistMat(:,nStimCell)*distConv >= distThresh);
    respMat(validCells,nStimCell) = mean(visResid(theseTri,validCells))';
end
nRespMat = bsxfun(@rdivide,respMat,shufMAD' * 1.253);
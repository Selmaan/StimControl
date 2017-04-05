function [probResp, gamParams, oddsAbove, oddsBelow, shufResp] = shuffleInfluenceMap(tV,de,respCells,stimCells,...
    validTargetsCell,nShuffles,stimFrameOffsets,shufOffset,stimRepeats,trimPrct)

offsetMat = repmat(stimFrameOffsets(:),1,stimRepeats)+shufOffset;

% shufMat=[];
% ctrlMat=[];

shufResp = nan(nShuffles,length(respCells)); %For non-parametrix, where shufResp itself is returned as argument
probResp = nan(length(stimCells),length(respCells));
oddsResp = nan(length(stimCells),length(respCells));
for iROI = 1:length(respCells)
    % Get valid stim onset times
    nROI = respCells(iROI);
    fprintf('Shuffling Response %d of %d \n',iROI,length(respCells)),
    validTargets = validTargetsCell{nROI};
    sel = ismember(tV.nTarg,validTargets);
    validOnsets = cellfun(@min,tV.stimFrames(sel));
    tmpShuffle = nan(nShuffles,1);
    
    % Calculate shuffles and fit with a gamma distribution
    parfor nShuffle = 1:nShuffles
        thisShuf = randperm(length(validOnsets),stimRepeats);
        stimOnsets = validOnsets(thisShuf);
        respFrames = repmat(stimOnsets,length(stimFrameOffsets),1) + offsetMat;
%        shufResp(nShuffle) = mean(de(nROI,respFrames(:)));
        respVals = reshape(de(nROI,respFrames(:)),length(stimFrameOffsets),stimRepeats);
        tmpShuffle(nShuffle) = trimmean(mean(respVals,1),trimPrct,'weighted');
    end
    shufResp(:,iROI) = tmpShuffle;
    if sum(tmpShuffle ==0)>0
        tmpShuffle(tmpShuffle==0) = eps;
        warning('Zeros in Shuffle, replacing w/ eps'),
    end
    gamParams(iROI,:) = gamfit(tmpShuffle);
    
    % Calculate true responses for each stim target and sample prob under gamma
    for iStim = 1:length(stimCells)
        nStim = stimCells(iStim);
        trueSel = tV.nTarg == nStim;
        trueOnsets = cellfun(@min,tV.stimFrames(trueSel));
        respFrames = repmat(trueOnsets,length(stimFrameOffsets),1) + offsetMat - shufOffset;
%         thisResp = mean(de(nROI,respFrames(:)));
        respVals = reshape(de(nROI,respFrames(:)),length(stimFrameOffsets),stimRepeats);
        thisResp = trimmean(mean(respVals,1),trimPrct,'weighted');
        probResp(iStim,iROI) = gamcdf(thisResp,gamParams(iROI,1),gamParams(iROI,2));
        countRespAbove(iStim,iROI) = sum(thisResp>shufResp(:,iROI));
        countRespBelow(iStim,iROI) = sum(thisResp<shufResp(:,iROI));
    end
end

oddsAbove = log10(nShuffles./(nShuffles+1-countRespAbove));
oddsBelow = log10(nShuffles./(nShuffles+1-countRespBelow));

%% Non Parametric Approach
% shufBelow = nan(length(stimCells),length(respCells));
% shufAbove = nan(length(stimCells),length(respCells));
% for iROI = 1:length(respCells)
%     nROI = respCells(iROI);
%     shufBelow(:,iROI) = sum(bsxfun(@gt,respMat(stimCells,nROI),shufResp(:,iROI)'),2);
%     shufAbove(:,iROI) = sum(bsxfun(@lt,respMat(stimCells,nROI),shufResp(:,iROI)'),2);
% end
% belowOdds = nShuffles./(nShuffles+1-shufBelow);
% aboveOdds = nShuffles./(nShuffles+1-shufAbove);
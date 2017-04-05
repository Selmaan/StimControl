%% Make stimExpt
acqObj = resFOV1;
expName = 'm22_170222';
stimBlocks = logical([0 1 1 1 0]);
linFOVum = [500, 500];
syncFiles = dir('*.abf');
for i=1:length(syncFiles)
    syncFns{i} = fullfile(acqObj.defaultDir,syncFiles(i).name);
    stimFns{i} = fullfile(acqObj.defaultDir,sprintf('%s_%d',expName,i));
    resFns{i} = fullfile(acqObj.defaultDir,...
        sprintf('resFOV1_0000%d_00001.tif',i));
end

stimExpt = makeStimExpt(acqObj,expName,linFOVum,resFns);
stimExpt.syncFns = syncFns;
stimExpt.stimFns = stimFns;
stimExpt.stimBlocks = stimBlocks;
%% Extract Signals
cd(stimExpt.acq.defaultDir),
for nBlock = 1:length(stimExpt.syncFns)
    syncDat = abfload(stimExpt.syncFns{nBlock});
    stimExpt.frameTimes{nBlock} = find(syncDat(2:end,1)>1 & syncDat(1:end-1,1)<1);
    stimExpt.psychTimes{nBlock} = find(syncDat(2:end,2)>1 & syncDat(1:end-1,2)<1);
    stimExpt.psych2frame{nBlock} = interp1(stimExpt.frameTimes{nBlock},...
        1:length(stimExpt.frameTimes{nBlock}),stimExpt.psychTimes{nBlock},'next');
    if stimExpt.stimBlocks(nBlock)
        thisHeader = scanimage.util.opentif(stimExpt.fnRes{nBlock});
        stimExpt.stimOrder{nBlock} = thisHeader.SI.hPhotostim.sequenceSelectedStimuli-1;
    else
        stimExpt.stimOrder{nBlock} = [];
    end
    
    stimFID = fopen(stimExpt.stimFns{nBlock});
    stimExpt.stimInfo{nBlock} = fread(stimFID,'float64');
    fclose(stimFID);
end

stimFrames = cell(0);
for nBlock = find(stimExpt.stimBlocks)
    blockOffsetFrame = length(cat(1,stimExpt.frameTimes{1:nBlock-1}));
    stimFrames{nBlock} = blockOffsetFrame + stimExpt.psych2frame{nBlock}(1:length(stimExpt.stimOrder{nBlock}));
end

stimFrames = cat(1,stimFrames{stimExpt.stimBlocks});
stimFrames = repmat(stimFrames,1,4) + repmat(0:2:6,size(stimFrames,1),1);
stimFrames = stimFrames(:);
interpFrames = cell(0);
interpFrames{1} = stimFrames;
interpFrames{2} = stimFrames+1;
interpFrames{3} = stimFrames-1;

[dF_cells,dF_denoised,dF_deconv,...
    traceBs,traceGs,traceSNs,traceSnScales,A,b,f,cIds] = deconvCells_NMF(stimExpt.acq,[],interpFrames);
[i,j] = ind2sub([512,512],1:512^2);
cellFilts = bsxfun(@rdivide,A{1}(:,cIds{1}),sum(A{1}(:,cIds{1})));
cellCentroids = ([j;i]*cellFilts)';
[xWorld,yWorld] = intrinsicToWorld(stimExpt.resRA,...
    cellCentroids(:,1),cellCentroids(:,2));
cellCentroids = [xWorld,yWorld];
nStim = size(stimExpt.roiCentroid,1);
nCell = size(cellCentroids,1);
distMat = sqrt(sum((repmat(reshape(cellCentroids,nCell,1,2),[1 nStim 1]) -...
    repmat(reshape(stimExpt.roiCentroid,1,nStim,2),[nCell 1 1])).^2,3));
[mDistVal,mDistInd] = min(distMat * (stimExpt.xConvFactor/2 + stimExpt.yConvFactor/2));
figure,plot(mDistVal,'.','markersize',10),line([1 nStim],[7.5 7.5],'color','r'),

stimExpt.dF_cells = cell2mat(dF_cells);
stimExpt.dF_deconv = cell2mat(dF_deconv);
stimExpt.cIds = cell2mat(cIds);
stimExpt.cellStimDistMat = distMat;
stimExpt.cellStimInd = mDistInd;
stimExpt.cellStimDist = mDistVal;
stimExpt.cellCentroids = cellCentroids;

save('stimExpt','stimExpt'),

%% Synchronize
distThresh = 25;
deSmStd = 3;
distConv = stimExpt.xConvFactor;
deTmp = matConv(stimExpt.dF_deconv,deSmStd);
deResp = []; visOri = []; visCon = []; stimID = [];visAvg = [];visResid = [];
for nBlock = find(stimExpt.stimBlocks)
    blockOffsetFrame = length(cat(1,stimExpt.frameTimes{1:nBlock-1}));
    lastTrial = find(~isnan(stimExpt.psych2frame{nBlock}),1,'last')-2;
    visFrames = stimExpt.psych2frame{nBlock}(1:lastTrial) + blockOffsetFrame;
    thisVisOri = stimExpt.stimInfo{nBlock}((1:3:lastTrial*3)+4); %stimSynch grating angle
    thisVisCon = stimExpt.stimInfo{nBlock}((2:3:lastTrial*3)+4); %stimSynch Contrast
    thisStimID = stimExpt.stimOrder{nBlock}';
    thisStimID(end+1:length(thisVisOri)) = nan;
    respFrames = bsxfun(@plus,visFrames,-10:40)';
    thisDeResp = reshape(deTmp(:,respFrames),...
           [size(stimExpt.dF_deconv,1),size(respFrames)]);
    
    visOri = cat(1,visOri,thisVisOri);
    visCon = cat(1,visCon,thisVisCon);
    stimID = cat(1,stimID,thisStimID);
    deResp = cat(3,deResp,thisDeResp);
end


allDirs = unique(visOri);
allCon = unique(visCon);
for s=1:length(allDirs)
    for c=1:length(allCon)
        theseTrials = visOri==allDirs(s) & visCon==allCon(c);
        for n=1:size(stimExpt.cellStimDistMat,1)
            invalidStim = find(stimExpt.cellStimDistMat(n,:)...
                *distConv < distThresh);
            validInd = find(theseTrials & ~ismember(stimID,invalidStim));
            visAvg(n,:,s,c) = mean(deResp(n,:,validInd),3);
        end
        visResid(:,:,theseTrials) = bsxfun(@minus,deResp(:,:,theseTrials),visAvg(:,:,s,c));
    end
end

clear stimMag
for i=1:length(stimExpt.cellStimInd)
    theseTrials = find(stimID == i);
    stimMag(i) = mean(visResid(stimExpt.cellStimInd(i),16,theseTrials),3);
end

clear deTmp
% Plot Residuals for stim versus non-stim cells
figure,plot(squeeze(mean(mean(visResid(stimExpt.cellStimInd,:,:),1),3)))
hold on,plot(squeeze(mean(mean(visResid(setdiff(1:size(visResid,1),stimExpt.cellStimInd),:,:),1),3)))
ay = ylim;
line([16 16],[ay(1) ay(2)],'color','k','linestyle',':')

%% Bootstrap Bounds
nShuffles = 1e3;
nStimCells = length(stimExpt.cellStimInd);
nReps = sum(~isnan(stimID))/nStimCells;
nTrials = size(visResid,3);

tmpDist = stimExpt.cellStimDistMat*distConv;
validTrialsCell = cell(0);
for n = 1:size(tmpDist,1)
    invalidStim = find(tmpDist(n,:) < distThresh);
    validTrialsCell{n} = find(~ismember(stimID,invalidStim));
end
shufMat = nan(size(visResid,1),size(visResid,2),nShuffles);
for nShuffle=1:nShuffles
    for n=1:size(tmpDist,1)
        validTrials = validTrialsCell{n};
        subTri = validTrials(randperm(length(validTrials),nReps));
        shufMat(n,:,nShuffle) = mean(visResid(n,:,subTri),3);
    end
end
shufMAD = mean(abs(shufMat),3);

respMat = nan(size(visResid,1),size(visResid,2),nStimCells);
for nStimCell = 1:nStimCells
    theseTri = find(stimID==nStimCell);
    validCells = find(stimExpt.cellStimDistMat(:,nStimCell)*distConv >= distThresh);
    respMat(validCells,:,nStimCell) = mean(visResid(validCells,:,theseTri),3);
end
nRespMat = bsxfun(@rdivide,respMat,shufMAD);

%% Calculate Tuning Properties
corDifMat = nan(size(visResid,1),nStimCells);
for i=1:length(stimExpt.cellStimInd)
    theseTrials = validTrialsCell{stimExpt.cellStimInd(i)};
    tmp = reshape(deResp(:,10:25,theseTrials),size(deResp,1),[]);
    corDifMat(:,i) = corr(tmp',tmp(stimExpt.cellStimInd(i),:)');
    for nStim = 1:length(stimExpt.cellStimInd)
        nROI = stimExpt.cellStimInd(nStim);
        validTrials = intersect(theseTrials,validTrialsCell{nROI});
        corDifMat(nROI,i) = corr(tmp(nROI,:)',tmp(stimExpt.cellStimInd(i),:)');
    end
end

%% Response by Distance Plots
validCells = 1:size(nRespMat,1);
distWidth = 30;
tmpDist = stimExpt.cellStimDistMat(validCells,:)*stimExpt.xConvFactor;
tmpMask = (repmat(stimMag,length(validCells),1) > 0.2) & ...
    (repmat(stimExpt.cellStimDist,length(validCells),1) < 10);
tmpAng = corDifMat(validCells,:);

meanFig = figure;hold on;
madFig = figure;hold on;
proFig = figure; hold on;
proFig.CurrentAxes.YScale = 'log';
angFig = figure; hold on;

for respFrame = 10:3:22
    nResp = nan(500,1);
    nRespAbs = nan(500,1);
    nRespAng = nan(500,1);
    nRespProb = nan(500,1);
    tmpResp = squeeze(nRespMat(validCells,respFrame,:));

    for d=1:500
        theseResp = (tmpDist> d-distWidth) & (tmpDist<d+distWidth);
        theseResp = theseResp & tmpMask;
        theseVals = tmpResp(theseResp);
        invalidResp = find(isnan(theseVals));
        theseVals(invalidResp) = [];
        if ~isempty(theseVals)
            nResp(d) = trimmean(theseVals,5);
            nRespAbs(d) = mad(theseVals);
            theseAng = tmpAng(theseResp);
            theseAng(invalidResp) = [];
            [nRespAng(d),nRespProb(d)] = corr(theseAng,theseVals,'type','Spearman');
        end
    end

    figure(meanFig),plot(nResp,'linewidth',2)
    figure(madFig),plot(nRespAbs,'linewidth',2)
    figure(proFig),plot(nRespProb,'linewidth',2)
    figure(angFig),plot(nRespAng,'linewidth',2)
end

figure(meanFig),
axis tight
xlim([distThresh 500])
xlabel('Distance'),ylabel('mad above shuffle'),
title('Mean Residual'),
legend('t0','t3','t6','t9','t12')
figure(madFig),
axis tight
xlim([distThresh 500])
xlabel('Distance'),ylabel('residual mad'),
title('MAD Residual'),
figure(proFig),
axis tight
xlim([distThresh 500])
xlabel('Distance'),ylabel('p-value'),
title('Correlation Significance'),
figure(angFig),
axis tight
xlim([distThresh 500])
xlabel('Distance'),ylabel('correlation coefficient'),
title('Tuning-Residual correlation'),

%% respCorr and influence plots
validCells = 1:size(nRespMat,1);
% tmpMask = (repmat(stimMag,length(validCells),1) > 0.1) & ...
%     (repmat(stimExpt.cellStimDist,length(validCells),1) < 10);
tmpMask = (repmat(stimMag,length(validCells),1) > 0.2) & ...
    (repmat(stimExpt.cellStimDist,length(validCells),1) < 10 & ...
    stimExpt.cellStimDistMat*stimExpt.xConvFactor < 500);
tmpAng = corDifMat(validCells,:);
tmpResp = squeeze(mean(nRespMat(validCells,11:25,:),2));
x1=tmpAng(tmpMask);
x2=tmpResp(tmpMask);
clear prcCor prcResp,
for i=0:95
    lowB = prctile(x1,i);
    highB = prctile(x1,i+5);
    prcResp(i+1) = nanmean(x2(x1>=lowB & x1<=highB));
    prcCor(i+1) = nanmean(x1(x1>=lowB & x1<=highB));
end
figure,plot(prcCor,prcResp,'k','linewidth',2),
axis tight,
ax = xlim;
stdBounds = 2/sqrt(sum(tmpMask(:))/20);
line(ax.*[1 1],stdBounds.*[1 1],'color','r','linestyle','--')
line(ax.*[1 1],-stdBounds.*[1 1],'color','r','linestyle','--')
xlabel('Response Correlation'),
ylabel('Influence'),
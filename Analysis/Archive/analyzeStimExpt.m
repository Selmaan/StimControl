cd(resFOV1.defaultDir),
acqObj = resFOV1;
%% PreProcessing
expName = 'm18_170219';
syncFiles = dir('*.abf');
for i=1:length(syncFiles)
    syncFns{i} = fullfile(acqObj.defaultDir,syncFiles(i).name);
    stimFns{i} = fullfile(acqObj.defaultDir,sprintf('%s_%d',expName,i));
    resFns{i} = fullfile(acqObj.defaultDir,...
        sprintf('resFOV1_0000%d_00001.tif',i));
end

linFOVum = [500, 500];
stimExpt = makeStimExpt(acqObj,expName,linFOVum,resFns);
stimExpt.syncFns = syncFns;
stimExpt.stimFns = stimFns;
save('stimExpt','stimExpt'),
figure(7),imshow(imNorm(meanRef(stimExpt.acq)),stimExpt.resRA),hold on,
figure(8),imshow(stimExpt.rLin,stimExpt.linRA),hold on,imcontrast
figure(9),imshow(stimExpt.gLin,stimExpt.linRA),hold on,imcontrast

%% Extract Signals
cd(stimExpt.acq.defaultDir),
stimFrames = cell(0);
for nBlock = 1:stimExpt.numStimBlocks
    syncDat = abfload(stimExpt.syncFns{nBlock});
    stimExpt.frameTimes{nBlock} = find(syncDat(2:end,1)>1 & syncDat(1:end-1,1)<1);
    stimExpt.psychTimes{nBlock} = find(syncDat(2:end,2)>1 & syncDat(1:end-1,2)<1);
    stimExpt.psych2frame{nBlock} = interp1(stimExpt.frameTimes{nBlock},...
        1:length(stimExpt.frameTimes{nBlock}),stimExpt.psychTimes{nBlock},'next');
    thisHeader = scanimage.util.opentif(stimExpt.fnRes{nBlock});
    stimExpt.stimOrder{nBlock} = thisHeader.SI.hPhotostim.sequenceSelectedStimuli-1;
    
    stimFID = fopen(stimExpt.stimFns{nBlock});
    stimExpt.stimInfo{nBlock} = fread(stimFID,'float64');
    fclose(stimFID);
    
    blockOffsetFrame = length(cat(1,stimExpt.frameTimes{1:nBlock-1}));
    stimFrames{nBlock} = blockOffsetFrame + stimExpt.psych2frame{nBlock}(1:length(stimExpt.stimOrder{nBlock}));
end

stimFrames = cat(1,stimFrames{:});
stimFrames = repmat(stimFrames,1,8) + repmat(0:2:14,size(stimFrames,1),1);
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
% [xIntrinsic,yIntrinsic] = worldToIntrinsic(stimExpt.resRA,...
%     stimExpt.roiCentroid(:,1),stimExpt.roiCentroid(:,2));
% stimCentroids = [xIntrinsic,yIntrinsic];
nStim = size(stimExpt.roiCentroid,1);
nCell = size(cellCentroids,1);
distMat = sqrt(sum((repmat(reshape(cellCentroids,nCell,1,2),[1 nStim 1]) -...
    repmat(reshape(stimExpt.roiCentroid,1,nStim,2),[nCell 1 1])).^2,3));
[mDistVal,mDistInd] = min(distMat * (stimExpt.xConvFactor/2 + stimExpt.yConvFactor/2));
figure,plot(mDistVal,'.','markersize',10),line([1 nStim],[7.5 7.5],'color','r'),
% mDistInd(mDistVal>7.5) = 0;

stimExpt.dF_cells = cell2mat(dF_cells);
stimExpt.dF_deconv = cell2mat(dF_deconv);
stimExpt.cIds = cell2mat(cIds);
stimExpt.cellStimDistMat = distMat;
stimExpt.cellStimInd = mDistInd;
stimExpt.cellStimDist = mDistVal;
stimExpt.cellCentroids = cellCentroids;

save('stimExpt','stimExpt'),
%% Synchronize
% contrastMod = 0;
distThresh = 30;
deSmStd = 6;
contrastMod = length(cell2mat(stimExpt.stimInfo'))/...
    length(cell2mat(stimExpt.stimOrder)) > 3;
distConv = stimExpt.xConvFactor;
deTmp = matConv(stimExpt.dF_deconv,deSmStd);
dfResp = []; deResp = []; visOri = []; visCon = []; stimID = [];visAvg = [];visResid = [];
for nBlock = 1:stimExpt.numStimBlocks
    blockOffsetFrame = length(cat(1,stimExpt.frameTimes{1:nBlock-1}));
    lastTrial = find(~isnan(stimExpt.psych2frame{nBlock}),1,'last')-2;
    visFrames = stimExpt.psych2frame{nBlock}(1:lastTrial) + blockOffsetFrame;
    if contrastMod==0
        thisVisOri = stimExpt.stimInfo{nBlock}((1:lastTrial)+4); %stimSynchGratings only grating angle
    elseif contrastMod==1
        thisVisOri = stimExpt.stimInfo{nBlock}((1:3:lastTrial*3)+4); %stimSynch grating angle
        thisVisCon = stimExpt.stimInfo{nBlock}((2:3:lastTrial*3)+4); %stimSynch Contrast
    end
    thisStimID = stimExpt.stimOrder{nBlock}';
    thisStimID(end+1:length(thisVisOri)) = nan;
    respFrames = bsxfun(@plus,visFrames,-30:90)';
    thisDfResp = reshape(stimExpt.dF_cells(:,respFrames),...
           [size(stimExpt.dF_cells,1),size(respFrames)]);
    thisDeResp = reshape(deTmp(:,respFrames),...
           [size(stimExpt.dF_cells,1),size(respFrames)]);
    
    visOri = cat(1,visOri,thisVisOri);
    if contrastMod==1
        visCon = cat(1,visCon,thisVisCon);
    end
    stimID = cat(1,stimID,thisStimID);
    dfResp = cat(3,dfResp,thisDfResp);
    deResp = cat(3,deResp,thisDeResp);
end

if contrastMod==0
    allDirs = unique(visOri);
    for i=1:length(allDirs)
        theseAng = visOri==allDirs(i);
        for n=1:size(stimExpt.cellStimDistMat,1)
            invalidStim = find(stimExpt.cellStimDistMat(n,:)...
                *distConv < distThresh);
            validInd = find(theseAng & ~ismember(stimID,invalidStim));
            visAvg(n,:,i) = mean(deResp(n,:,validInd),3);
        end
        visResid(:,:,theseAng) = bsxfun(@minus,deResp(:,:,theseAng),visAvg(:,:,i));
    end
elseif contrastMod==1
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
end

clear stimMag
for i=1:length(stimExpt.cellStimInd)
    theseTrials = find(stimID == i);
    stimMag(i) = mean(visResid(stimExpt.cellStimInd(i),40,theseTrials),3);
end

clear deTmp
% Plot Residuals for all cells and for 
figure,plot(squeeze(mean(mean(visResid(stimExpt.cellStimInd,:,:),1),3)))
hold on,plot(squeeze(mean(mean(visResid(setdiff(1:size(visResid,1),stimExpt.cellStimInd),:,:),1),3)))
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

%% calculate angular differences
if length(size(visAvg))==4
    visPref = squeeze(mean(visAvg(:,50,:,:),4));
else
    visPref = squeeze(visAvg(:,50,:));
end
visPref = bsxfun(@rdivide,visPref,sum(visPref,2));
R = [sum(bsxfun(@times,visPref,sind(90:90:720)),2),...
    sum(bsxfun(@times,visPref,cosd(90:90:720)),2)];
magR = sqrt(sum(R.^2,2));
angR = atan2d(R(:,1),R(:,2));
angDifMat = abs(bsxfun(@minus,angR,angR(stimExpt.cellStimInd)'));
angDifMat = min(cat(3,angDifMat,360-angDifMat),[],3);

corDifMat = nan(size(visResid,1),nStimCells);
for i=1:length(stimExpt.cellStimInd)
    theseTrials = validTrialsCell{stimExpt.cellStimInd(i)};
    tmp = reshape(deResp(:,30:80,theseTrials),size(deResp,1),[]);
    corDifMat(:,i) = corr(tmp',tmp(stimExpt.cellStimInd(i),:)');
    for nStim = 1:length(stimExpt.cellStimInd)
        nROI = stimExpt.cellStimInd(nStim);
        validTrials = intersect(theseTrials,validTrialsCell{nROI});
        corDifMat(nROI,i) = corr(tmp(nROI,:)',tmp(stimExpt.cellStimInd(i),:)');
    end
end
% tmp = reshape(deResp(:,30:80,:),size(deResp,1),[]);
% respMag = std(tmp')';
%% Response by Distance Plots
validCells = 1:size(nRespMat,1);
distWidth = 60;
tmpDist = stimExpt.cellStimDistMat(validCells,:)*stimExpt.xConvFactor;
tmpMask = (repmat(stimMag,length(validCells),1) > 0.1) & ...
    (repmat(stimExpt.cellStimDist,length(validCells),1) < 10);
% tmpMask = (repmat(stimMag,length(validCells),1) > 0.1) & ...
%     (repmat(magR(validCells),1,length(stimExpt.cellStimInd)) > 0.15) & ...
%     (repmat(magR(stimExpt.cellStimInd)',length(validCells),1) > 0.15);
% tmpMask = (repmat(stimMag,length(validCells),1) > 0.1) & ...
%     (repmat(respMag(validCells),1,length(stimExpt.cellStimInd)) < prctile(respMag,100)) & ...
%     (repmat(respMag(stimExpt.cellStimInd)',length(validCells),1) < prctile(respMag,50));
% tmpAng = angDifMat(validCells,:);
tmpAng = corDifMat(validCells,:);

meanFig = figure;hold on;
madFig = figure;hold on;
proFig = figure; hold on;
proFig.CurrentAxes.YScale = 'log';
angFig = figure; hold on;

for respFrame = 30:6:54
    clear nResp nRespAbs nRespProb nRespAng
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
%             [~,nRespProb(d)] = kstest(theseVals/1.253); %convert MAD to std units
%             nRespAng(d) = corr(theseAng,theseVals,'type','Spearman');
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
legend('t0','t6','t12','t18','t24')
figure(madFig),
axis tight
xlim([distThresh 500])
xlabel('Distance'),ylabel('residual mad'),
title('MAD Residual'),
figure(proFig),
axis tight
xlim([distThresh 500])
xlabel('Distance'),ylabel('p-value'),
title('Significance'),
figure(angFig),
axis tight
xlim([distThresh 500])
xlabel('Distance'),ylabel('correlation coefficient'),
title('Tuning-Residual correlation'),

%% respCorr and influence plots
validCells = 1:size(nRespMat,1);
% tmpMask = (repmat(stimMag,length(validCells),1) > 0.1) & ...
%     (repmat(stimExpt.cellStimDist,length(validCells),1) < 10);
tmpMask = (repmat(stimMag,length(validCells),1) > 0.1) & ...
    (repmat(stimExpt.cellStimDist,length(validCells),1) < 10 & ...
    stimExpt.cellStimDistMat*stimExpt.xConvFactor < 250);
tmpAng = corDifMat(validCells,:);
tmpResp = squeeze(mean(nRespMat(validCells,30:45,:),2));
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


%% save ROI info (archival)
stimExpt = calcDistMats(stimExpt);




stimExpt.lineArtBlocks{1} = 1:17;
stimExpt.lineArtBlocks{2} = 18:285;
stimExpt.lineArtBlocks{3} = 286:512;
stimOnsets = stimExpt.exF(1,:);
stimExpt.linArtFrames{1} = [stimOnsets+2, stimOnsets+5, stimOnsets+8];
stimExpt.linArtFrames{2} = [stimOnsets, stimOnsets+3, stimOnsets+6];
stimExpt.linArtFrames{3} = [stimOnsets+1, stimOnsets+4, stimOnsets+7];

stimExpt = extractROIsStim(stimExpt);
dF = dFcalc(stimExpt.t,stimExpt.r,'custom_wfun', stimExpt.acqBlocks);
stimExpt.dF = dF;

cDe = nan(size(dF));
de = nan(size(dF));
gAll = nan(size(dF,1),3);
parfor nNeur=1:size(dF,1)
    nNeur,
    [cDe(nNeur,:),bAll(nNeur),c1All(nNeur),thisG,snAll(nNeur),sp]...
        = constrained_foopsi(dF(nNeur,:));
    pM = max(impulseAR(gAll(nNeur,:)));
    de(nNeur,:) = sp*pM*20;
    if length(thisG) == 3
        gAll(nNeur,:) = thisG;
    end
end

stimExpt.cDe = cDe; stimExpt.de = de; stimExpt.bAll = bAll;
stimExpt.c1All = c1All; stimExpt.gAll = gAll; stimExpt.snAll = snAll;
clear cDe de bAll c1All gAll snAll sp dF

cd(stimExpt.acq.defaultDir),
stimExpt = calcRespProps(stimExpt,0:11);
save('stimExpt','stimExpt'),

% allShifts = [resFOV1.shifts.slice];
% xShift = [];
% yShift = [];
% for nMov = 1:length(allShifts)
%     nMov,
%     x = squeeze(median(reshape(allShifts(nMov).x(),512^2,1,[])));
%     y = squeeze(median(reshape(allShifts(nMov).y(),512^2,1,[])));
%     xShift = cat(1,xShift,x);
%     yShift = cat(1,yShift,y);
% end

% fullShift = sqrt((xShift-median(xShift)).^2 + (yShift-median(yShift)).^2);
% figure,histogram(fullShift,'Normalization','cdf'),
% prctile(fullShift,99),

% save('trace + stim','dF','tV','t','r','roi','pil','de','cDe','gAll','snAll','bAll',....
%     'roiCentroid','resRA','linRA','xShift','yShift')

%% Exploration
% nROI = nROI + 1;
for nROI = unique(stimExpt.tV.nTarg)
    dispStimPair(stimExpt,nROI),
    fprintf('ROI #%d, group %d \n',nROI,stimExpt.roi(nROI).group),
    pause,
end

% stimExpt = calcRespProps(stimExpt,0:11);

%% Shuffle Analysis
nShuffles = 1e6;
distThresh = 30;
trimPrct = 2;
stimCells = find([stimExpt.roi.group]==4);
% respCells = find([roi.group]==1);
respCells = 1:length(stimExpt.roi);
stimFrameOffsets = 0:11;
shufOffset = 15;
stimRepeats = size(stimExpt.pkStim,3);
shufDist = stimExpt.acqDistMat;

validTargetsCell = {};
for nROI = respCells
    validTargetsCell{nROI} = stimCells(shufDist(stimCells,nROI)>distThresh);
end

[probResp, gamParams, oddsAbove, oddsBelow, shufResp] = shuffleInfluenceMap(...
    stimExpt.tV,stimExpt.de,respCells,stimCells,...
    validTargetsCell,nShuffles,stimFrameOffsets,shufOffset,stimRepeats,trimPrct);

probAbove = -log10(1-probResp);
probBelow = -log10(probResp);

% makeConnectionShufFigs,
%% Off Target Analysis

nROI = 1;
offTargCounter = 17;

for nTarg = (nROI-1)*offTargCounter + 1 : nROI*offTargCounter
    flowScript_exploration,
    nTarg-(nROI-1)*offTargCounter-1,
%     roiDist(nTarg,nROI),
    pause,
end

% for nROI=1:4
%     figure;[~,xSorted] = sort(roiDist(:,nROI));
%     plot(roiDist(xSorted,nROI),respMat(xSorted,nROI),'.','markersize',20),
%     title(sprintf('Cell %d',nROI)),axis tight
%     ay = ylim;xlabel('Distance (um)'),ylabel('Response (spikes)'),
%     line([20 20],[ay(1) ay(2)],'color','k')
% end

%% Distance Plots
roiDist = shufDist(stimCells,respCells);
o = oddsAbove;

stimDists = {};
% stimDists{1} = roiDist==0;
stimDists{1} = roiDist>0 & roiDist<25;
stimDists{2} = roiDist>25 & roiDist<40;
stimDists{3} = roiDist>40 & roiDist<80;
stimDists{4} = roiDist>80 & roiDist<120;
stimDists{5} = roiDist>120;
dBinCol = jet(length(stimDists))*.86;

figure,
for i=1:length(stimDists)
    [f,x] = ecdf(o(stimDists{i}));
    semilogy(x(2:end),1-f(1:end-1),'linewidth',2,'color',dBinCol(i,:)),
    hold on,
end
plot([0 6],[1 1e-6],'k')


%% Sparse Exp Analysis
figure,boxplot(stimMag,[roi.group]),
goodNeur = find(ismember([roi.group],[1 3 4 6]));
stimCells = find([roi.group]<4);
stimCells = stimCells(ismember(stimCells,goodNeur));
nonExp = find([roi.group]>3);
nonExp = nonExp(ismember(nonExp,goodNeur));
responders = oddsAbove(stimCells,nonExp);
stimulated = oddsAbove(nonExp,stimCells);
figure,plot(distMat(stimCells,nonExp),responders,'.')
title('Non-Expressing Cells response to Stimulatable Stim')
figure,plot(distMat(nonExp,stimCells),stimulated,'.')
xlabel('Pixel Distance')
ylabel('Spikes post-Stim')
title('Stimulatable Cells response to Non-Expressing Stim')

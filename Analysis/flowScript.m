%% PreProcessing

baseDir = fileparts(expt1.correctedMovies.slice.channel.fileName{1});
fnRes = [baseDir '\expt1_00001_00001.tif'];
fnLin = [baseDir, '\linFOV1_1.tif'];

temp2015alignment,

[resRef,resRefRA] = imwarp(meanRef(expt1),resRA,res2lin);
figure(7),imshow(imNorm(resRef),resRefRA),hold on,
figure(8),imshow(imNorm(rLin),linRA),hold on,

%% Selection
ITI = header.SI.hUserFunctions.userFunctionsCfg__1.Arguments{1};
stimOrder = header.SI.hPhotostim.sequenceSelectedStimuli-1;
stimFrameDur = round(stimGroups(end).rois(2).scanfields.duration/30e-3);
exF = ITI:ITI:ITI*length(stimOrder);
for i=2:stimFrameDur
    exF(i,:) = exF(1,:)+(i-1);
end
for i=1:length(stimOrder)
    tV.nTarg(i) = stimOrder(i);
    tV.stimFrames{i} = exF(:,i);
end
exF = exF(:);
selectROIs(expt1,[],[],[],[],exF);

nROI = 0;
%% Highlight next ROI
if nROI>0
    figure(7),plot(roiCentroid(nROI,1),roiCentroid(nROI,2),'k+','markersize',10),
    figure(8),plot(roiCentroid(nROI,1),roiCentroid(nROI,2),'k+','markersize',10),
end
nROI = nROI + 1,
figure(7),plot(roiCentroid(nROI,1),roiCentroid(nROI,2),'r+','markersize',10),
figure(8),plot(roiCentroid(nROI,1),roiCentroid(nROI,2),'r+','markersize',10),

% ref = meanRef(rFOV1); %ref = imresize(ref,2);
% ref(isnan(ref)) = 0; ref(ref<0) = 0;
% load('C:\Users\Selmaan\Documents\MATLAB\r2s_25x.mat'),
% sReg = imwarp(imresize(ref,1.4),r2s,'OutputView',imref2d(size(ref)));
% tV = vecTrials(stimExpt);
% exF = reshape([tV.stimFrames{:}],,[]);
% selectROIs(rFOV1,[],[],[],[],exF);
% hEl = dispStimROIs(stimExpt.StimROIs,adapthisteq(imNorm(sReg)));
% hEl2 = dispStimROIs(stimExpt.StimROIs);
% nROI = 1;
% [tOff, tOn, tOff2, tOn2] = blinkROI;

%% save ROI info
cd(expt1.defaultDir),
expt1.save
[dF,t,r,roi,pil] = extractROIsBin(expt1);
for i=1:length(tV.stimFrames)
    stimFrame = tV.stimFrames{i};
    preVals = dF(:,stimFrame(1)-1);
    postVals = dF(:,stimFrame(end)+1);
    interpDenom = length(stimFrame) + 1;
    for frameInd = 1:length(stimFrame)
        dF(:,stimFrame(frameInd)) = (interpDenom-frameInd)/interpDenom * preVals ...
            + frameInd/interpDenom * postVals;
    end
end

de = nan(size(dF));
for nNeur=1:size(dF,1)
    nNeur,
    de(nNeur,:) = getDeconv(dF(nNeur,:));
end

allShifts = [expt1.shifts.slice];
xShift = [];
yShift = [];
for nMov = 1:length(allShifts)
    nMov,
    x = squeeze(mean(reshape(allShifts(nMov).x(),[],1,1e3)));
    y = squeeze(mean(reshape(allShifts(nMov).y(),[],1,1e3)));
    xShift = cat(1,xShift,x);
    yShift = cat(1,yShift,y);
end
    
save('trace + stim','dF','tV','de','t','r','roi','pil',...
    'xShift','yShift','roiCentroid','resWarpRA','linRA')

%% Exploration
nROI = nROI + 1,
nTarg = nROI;
flowScript_exploration;
%% Automation / extra analyses
flowScript_population;
distMat = 310*distMat/linRA.ImageExtentInWorldX;
stimMag = median(repStim(:,1:10),2);
%goodNeur = find(stimMag>prctile(stimMag,25));
goodNeur = find([roi.group]==1);
respMat = mean(pkStim,3);
makePopStimFigs;

%% power dependency

s10 = 3:3:size(roiCentroid,1);
s25 = 1:3:size(roiCentroid,1);
s50 = 2:3:size(roiCentroid,1);
sum(ismember(goodNeur,s10)),
sum(ismember(goodNeur,s25)),
sum(ismember(goodNeur,s50)),

figure,hold on, ind = goodNeur;
plot(expLvl(ind),stimMag(ind),'.','markersize',10)
ind = intersect(goodNeur,s10);
plot(expLvl(ind),stimMag(ind),'.','markersize',10)
ind = intersect(goodNeur,s25);
plot(expLvl(ind),stimMag(ind),'.','markersize',10)
ind = intersect(goodNeur,s50);
plot(expLvl(ind),stimMag(ind),'.','markersize',10)
xlabel('C1V1 Expression'),
ylabel('Response Spikes'),
legend('All','8%','24%','72%')

figure,hold on,ind = goodNeur;
plot(mean(repStim(ind,:)))
ind = intersect(goodNeur,s10);
plot(mean(repStim(ind,:)))
ind = intersect(goodNeur,s25);
plot(mean(repStim(ind,:)))
ind = intersect(goodNeur,s50);
plot(mean(repStim(ind,:)))
xlabel('Stim Repeat')
ylabel('Stim Response (spikes)')
legend('All','8%','24%','72%')

figure,hold on,ind = goodNeur;
plot(mean(repStim(ind,:))/mean(stimMag(ind)))
ind = intersect(goodNeur,s10);
plot(mean(repStim(ind,:))/mean(stimMag(ind)))
ind = intersect(goodNeur,s25);
plot(mean(repStim(ind,:))/mean(stimMag(ind)))
ind = intersect(goodNeur,s50);
plot(mean(repStim(ind,:))/mean(stimMag(ind)))
xlabel('Stim Repeat')
ylabel('Stim Response (normalized)')
legend('All','8%','24%','72%')
%% Shuffle Analysis
nShuffles = 1e5;
distThresh = 30;
spkThresh = 3;

makeConnectionShufFigs,


%% Archive
shufResp = nan(size(de,1),nShuffles);
for nShuffle = 1:nShuffles
    if mod(nShuffle,100) == 0
        nShuffle,
    end
    for nTarg = 1:size(dF,1)
        sel = tV.nTarg == nTarg;
        validForShuf = tV.stimFrames(~sel);
        shufSelection = [randperm(length(validForShuf)),randperm(length(validForShuf),sum(sel))];
        shufFrames = validForShuf(shufSelection);
        stimOnsets = cellfun(@min, shufFrames(sel));
        shufTrialResp = nan(length(stimOnsets),1);
        for stimTrial = 1:length(stimOnsets)
            stimOnset = stimOnsets(stimTrial);
            shufTrialResp(stimTrial) = ...
                sum(de(nTarg,stimOnset:stimOnset+10),2);
        end
        shufResp(nTarg,nShuffle) = mean(shufTrialResp);
    end
end

mShuf = mean(shufResp,2);
sShuf = std(shufResp,[],2);
figure,plot(mShuf,sShuf,'.')
hold on,plot(0:1e-1:.2,0:1e-1:.2)
zRespMat = respMat;
for i = 1:size(dF,1)
    for j = 1:size(dF,1)
    zRespMat(i,j) = sum(respMat(i,j)>shufResp(j,:));
    end
end
gzRespMat = zRespMat(goodNeur,goodNeur);
%figure,imagesc(nShuffles./(nShuffles-gzRespMat)),
gDistMat = distMat(goodNeur,goodNeur);
offDiag = gzRespMat(gDistMat>20);
offDiagDist = gDistMat(gDistMat>20);
for thresh = 1:nShuffles
    respRatio(thresh) = sum(offDiag>=(nShuffles+1-thresh))/(length(offDiag)*(thresh/nShuffles));
end
figure,plot(respRatio)
%% Sparse Exp Analysis
figure,boxplot(stimMag,[roi.group]),
nonExp = find([roi.group]>3);
nonExp = nonExp(~ismember(nonExp,goodNeur));
responders = respMat(goodNeur,nonExp);
stimulated = respMat(nonExp,goodNeur);
figure,plot(distMat(goodNeur,nonExp),responders,'.')
title('Non-Expressing Cells response to Stimulatable Stim')
figure,plot(distMat(nonExp,goodNeur),stimulated,'.')
xlabel('Pixel Distance')
ylabel('Spikes post-Stim')
title('Stimulatable Cells response to Non-Expressing Stim')

%% GLM fit
nFit = nROI;
sel = find(tV.nTarg == nFit);
nNeurons = size(de,1);
predMat = nan(nNeurons,length(tV.nTarg));
for n=1:nNeurons
    predMat(n,:) = tV.nTarg == n;
end
predMat(nNeurons+1,:) = linspace(0,1,length(tV.nTarg));
predMat(nNeurons+2,:) = sqrt(linspace(0,1,length(tV.nTarg)));
predMat(nNeurons+3,:) = 0;
predMat(nNeurons+4,:) = 0;
predMat(nNeurons+5,:) = 0;
resp = nan(length(tV.stimFrames),1);
for i=1:length(tV.stimFrames)
    respFrames = tV.stimFrames{i}(1):10+tV.stimFrames{i}(1);
    resp(i) = sum(de(nFit,respFrames));
    lastStim = find(sel<i,1,'last');
    if ~isempty(lastStim)
        predMat(nNeurons+3,i) = exp(sel(lastStim)-i);
    end
    predMat(nNeurons+4,i) = mean(xShift(tV.stimFrames{i}));
    predMat(nNeurons+5,i) = mean(yShift(tV.stimFrames{i}));
end
predMat(nNeurons+4,:) = predMat(nNeurons+4,:) - median(xShift);
predMat(nNeurons+5,:) = predMat(nNeurons+5,:) - median(xShift);
%mdl = stepwiseglm(predMat',resp,'constant','upper','linear','Distribution','poisson');

display('Fitting...'),
[B,fitinfo] = lassoglm(predMat',resp,'poisson','CV',10,'LambdaRatio',5e-4,'NumLambda',50);
lassoPlot(B,fitinfo,'plottype','CV');
lassoPlot(B,fitinfo,'PlotType','Lambda','XScale','log');
figure,plot(distMat(:,nFit),B(1:nNeurons,fitinfo.IndexMinDeviance),'.')
B(nNeurons+1:end,fitinfo.IndexMinDeviance),

%% Archive
% resp = [];
% for nROI = 1:43
%     nTarg = nROI;
%     sel = (tMed) & tV.nTarg == nTarg;
%     s = getTrigStim(dF,tV,sel,nROI,0);
%     %resp(:,nROI) = [mean(s(1:19,55:65),2);mean(s(21:40,115:125),2)];
%     resp(nROI,:) = mean(s);
%     m = createMask(hEl(nROI));
%     mCh(nROI) = mean(mean(double(stimExpt.StimROIs.imData(:,:,2).*m)));
%     mGC(nROI) = mean(mean(double(stimExpt.StimROIs.imData(:,:,1).*m)));
% end
% 
% pk = mean(resp(:,118:125),2);
% figure,plot(resp')
% figure,plot(mCh,pk,'.')
% figure,plot(mGC,pk,'.')
% figure,plot(mCh,mGC,'.')

% for i = 1:size(dF,1)
%     nROI = i;nTarg = i;
%     sel = tV.nTarg == nTarg;
%     s3(:,:,i) = getTrigStim(dF,tV,sel & t3,nROI,0,0);
%     s6(:,:,i) = getTrigStim(dF,tV,sel & t6,nROI,0,0);
%     s9(:,:,i) = getTrigStim(dF,tV,sel & t9,nROI,0,0);
%     s13(:,:,i) = getTrigStim(dF,tV,sel & t13,nROI,0,0);
% end
% s2=[];s4=[];s8=[];s16=[];
% for i = 1:length(g)
%     iTarg = g(i);
%     nROI = iTarg;nTarg = iTarg;
%     sel = tV.nTarg == nTarg;
%     s2(:,:,i) = getTrigStim(dF,tV,sel & t2,nROI,0,0);
%     s4(:,:,i) = getTrigStim(dF,tV,sel & t4,nROI,0,0);
%     s8(:,:,i) = getTrigStim(dF,tV,sel & t8,nROI,0,0);
%     s16(:,:,i) = getTrigStim(dF,tV,sel & t16,nROI,0,0);
% end
% 
% figure,hold on,
% plot(max(mean(s2,3),[],2))
% plot(max(mean(s4,3),[],2))
% plot(max(mean(s8,3),[],2))
% plot(max(mean(s16,3),[],2))

%% PreProcessing

fnRes = 'E:\Data\SomaLocalized\c78\15_07_17\expt1_00001_00001.tif';
fnLin = 'E:\Data\SomaLocalized\c78\15_07_17\sFOV1_2.tif';

temp2015alignment,

figure(7),imshow(imNorm(resWarp),resWarpRA),hold on,
figure(8),imshow(imNorm(rLinWarp),rLinWarpRA),hold on,

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
% exF = reshape([tV.stimFrames{:}],1,[]);
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
    blankVal = dF(:,stimFrame(1)-1)/2+dF(:,stimFrame(end)+1)/2;
    dF(:,stimFrame) = repmat(blankVal,1,length(stimFrame));
end

de = nan(size(dF));
for i=1:size(dF,1)
    i,
    de(i,:) = getDeconv(dF(i,:));
end

allShifts = [expt1.shifts.slice];
xShift = [];
yShift = [];
for i = 1:length(allShifts)
    i,
    x = squeeze(mean(reshape(allShifts(i).x(),[],1,1e3)));
    y = squeeze(mean(reshape(allShifts(i).y(),[],1,1e3)));
    xShift = cat(1,xShift,x);
    yShift = cat(1,yShift,y);
end
    
save('trace + stim','dF','tV','de','t','r','roi','pil','xShift','yShift')

%% Exploration
nROI = nROI + 1,
nTarg = nROI;
flowScript_exploration;
%% Automation / extra analyses
flowScript_population;
distMat = distMat/rLinWarpRA.ImageExtentInWorldX*500;
stimMag = median(repStim(:,1:10),2);
%goodNeur = find(stimMag>prctile(stimMag,25));
goodNeur = find([expt1.roiInfo.slice.roi.group]==1);
figure,imagesc(corrcoef(repStim(goodNeur,:))-eye(size(repStim,2)))
figure,plot(repStim(goodNeur,:)'),hold on,plot(mean(repStim(goodNeur,:)),'k','linewidth',2)
respMat = mean(pkStim,3); figure,imagesc(respMat)
respMatG = respMat(goodNeur,goodNeur);
distMatG = distMat(goodNeur,goodNeur);
[sortDist,sortDistInd] = sort(distMatG,1,'ascend');
sortResp = [];
for i=1:size(respMatG,2)
    sortResp(:,i) = respMatG(sortDistInd(:,i),i);
end
figure,plot(sortDist,sortResp,':')
hold on
plot(sortDist,sortResp,'.','markersize',10)
d0 = distMatG(:)==0;
d30 = distMatG(:)>0 & distMatG(:)<30;
d60 = distMatG(:)>30 & distMatG(:)<60;
d90 = distMatG(:)>60 & distMatG(:)<90;
d120 = distMatG(:)>90 & distMatG(:)<120;
dLarge = distMatG(:)>120;
plot([mean(distMatG(d0)), mean(distMatG(d30)), mean(distMatG(d60)), ...
    mean(distMatG(d90)), mean(distMatG(d120)), mean(distMatG(dLarge))],...
    [mean(respMatG(d0)), mean(respMatG(d30)), mean(respMatG(d60)), ...
    mean(respMatG(d90)), mean(respMatG(d120)), mean(respMatG(dLarge))],...
    'k','linewidth',2);
figure, hold on,
ecdf(respMatG(d0))
ecdf(respMatG(d30))
ecdf(respMatG(d60))
ecdf(respMatG(d90))
ecdf(respMatG(d120))
ecdf(respMatG(dLarge))

%% Expression level analysis
% roiMask = zeros(512);
% roiInfo = expt1.roiInfo.slice.roi;
% for i=1:length(roiInfo)
%     roiMask(roi(i).indBody) = i;
% end
% roiWarp = imwarp(roiMask,resRA,res2lin);
% figure,imshowpair(imNorm(resWarp),resWarpRA,roiWarp>0,resWarpRA),
% figure,imshowpair(imNorm(rLinWarp),rLinWarpRA,roiWarp>0,resWarpRA),
% roiFuse = imfuse(rLinWarp/1e3,rLinWarpRA,roiWarp/1e3,resWarpRA);
roiMask = zeros(512);
roiSizes = [0.0075 0.0075];
figure,imshow(imNorm(rLinWarp),rLinWarpRA),
for i=1:size(roiCentroid,1)
    roiLoc = roiCentroid(i,:);
    roiSize = roiSizes;
    h = imellipse(gca,[roiLoc-roiSize 2*roiSize]);
    m = createMask(h);
    expLvl(i) = mean(rLinWarp(m));
    %delete(h),
end
clear m

figure,plot(expLvl,stimMag,'.','markersize',10)
xlabel('C1V1 Expression'),
ylabel('Response Spikes'),
figure,plot(expLvl(goodNeur),stimMag(goodNeur),'.','markersize',10)
xlabel('C1V1 Expression'),
ylabel('Response Spikes'),
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
predMat = nan(size(de,1),length(tV.nTarg));
for n=1:size(de,1)
    predMat(n,:) = tV.nTarg == n;
end
predMat(end+1,:) = linspace(0,1,length(tV.nTarg));
predMat(end+1,:) = 0;
resp = nan(length(tV.stimFrames),1);
for i=1:length(tV.stimFrames)
    respFrames = tV.stimFrames{i}(1):10+tV.stimFrames{i}(1);
    resp(i) = sum(de(nFit,respFrames));
    lastStim = find(sel<i,1,'last');
    if ~isempty(lastStim)
        predMat(end,i) = exp(sel(lastStim)-i);
    end
end

%mdl = stepwiseglm(predMat',resp,'constant','upper','linear','Distribution','poisson');

display('Fitting...'),
[B,fitinfo] = lassoglm(predMat',resp,'poisson','CV',10,'LambdaRatio',5e-4,'NumLambda',50);
lassoPlot(B,fitinfo,'plottype','CV');
lassoPlot(B,fitinfo,'PlotType','Lambda','XScale','log');
figure,plot(distMat(:,nFit),B(1:end-2,fitinfo.IndexMinDeviance),'.')
B(end-1:end,fitinfo.IndexMinDeviance),

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

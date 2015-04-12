%% Selection
stimExpt = catStimExpt(fNames,framesPerExpt);
ref = meanRef(rFOV1);ref(isnan(ref)) = 0;ref = sqrt(ref);
load('C:\Users\Selmaan\Documents\MATLAB\r2s.mat'),
ref = imresize(ref,1.4);
sReg = imwarp(ref,r2s,'OutputView',imref2d(size(ref)));
tV = vecTrials(stimExpt);
exF = reshape([tV.stimFrames{:}],1,[]);
selectROIs(rFOV1,[],[],[],[],exF);
hEl = dispStimROIs(stimExpt.StimROIs,adapthisteq(imNorm(sRef)));
hEl2 = dispStimROIs(stimExpt.StimROIs);
nROI = 1;
[t1, t2] = blinkROI;

%% Selection Vectors
t3 = tV.pockPulseFreq == (1e5/3);
t6 = tV.pockPulseFreq == (1e5/6);
t9 = tV.pockPulseFreq == (1e5/9);
t13 = tV.pockPulseFreq == (1e5/13);

%% Exploration
nROI = 4;
nTarg = nROI;
x = (-240:300)/30;
%sel = (tMax|tMed) & tV.nTarg == nTarg & tV.nRepeat < 21;
sel = (tMed) & tV.nTarg == nTarg;
s = getTrigStim(dF,tV,sel,nROI,0,0);
c = jet(size(s,1));
figure(1),clf, hold on
for i=1:size(s,1)
    plot(x,s(i,:),'color',c(i,:))
end
axis tight
sD = getTrigStim(dF,tV,sel,nROI,0,1) * 30;
figure(2),clf,imagesc(x,1:size(sD,1),matConv(sD,3))
figure(3),clf,plot(x,mean(sD),'k'),
hold on,plot(x,median(matConv(sD,3)),'r','linewidth',2)
plot(x,mean(matConv(sD,3)),'g','linewidth',2)
axis tight,

figure(4),clf
cMap = flipud(parula(6));
trialConds = cat(1,t3,t6,t9,t13);
plot(dF(nROI,:),'k'),hold on,
allSel = tV.nTarg == nTarg;
for trial = find(allSel)
    stimFrame = tV.stimFrames{trial}(1);
    trialCond = find(trialConds(:,trial))+1;
    plot(stimFrame+15,dF(nROI,stimFrame+15),'.','markersize',25,...
        'color',cMap(trialCond,:)),
end
for trial = find(sel)
    stimFrame = tV.stimFrames{trial}(1);
    plot(stimFrame+15,dF(nROI,stimFrame+15),'r*','markersize',10),
end
%% Automation / extra analyses
% zdF = zscore(dF')';
% for trial = 1:length(tV.stimFrames)
%     dfStim(:,trial) = mean(zdF(:,tV.stimFrames{trial}(1)+10:tV.stimFrames{trial}(1)+20),2)...
%         -mean(zdF(:,tV.stimFrames{trial}(1)-11:tV.stimFrames{trial}(1)-1),2);
% end
% for trial = 1:length(tV.stimFrames)
%     stimOn = tV.stimFrames{trial};
%     deStim(:,trial) = mean(de(:,stimOn:stimOn+11),2);
% end

% resp = [];
% for nTarg = 1:size(deStim,1)
%     sel = (tV.nTarg == nTarg);
%     resp(:,nTarg) = median(dfStim(:,sel),2);
% end
% figure,imagesc(resp)


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
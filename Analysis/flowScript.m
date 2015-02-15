%% Selection
stimExpt = catStimExpt(fNames,framesPerExpt);
tV = vecTrials(stimExpt);
exF = reshape([tV.stimFrames{:}],1,[]);
selectROIs(rFOV1,[],[],[],[],exF);
hEl = dispStimROIs(stimExpt.StimROIs);
nROI = 1;
[t1 t2] = blinkROI;

%% Selection Vectors
tMax = tV.pockPulseFreq == 0;
tMed = tV.pockPulseFreq == 1e4;
tMin = tV.pockPulseFreq == 500;

%% Exploration
nROI = 5;
nTarg = nROI;
x = (-299:300)/30;
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
figure(2),clf,imagesc(matConv(sD,3))
figure(3),clf,plot(x,mean(sD),'k'),
hold on,plot(x,median(matConv(sD,3)),'r','linewidth',2)
plot(x,mean(matConv(sD,3)),'g','linewidth',2)
axis tight,

%% Automation
resp = [];
for nROI = 1:43
    nTarg = nROI;
    sel = (tMed) & tV.nTarg == nTarg;
    s = getTrigStim(dF,tV,sel,nROI,0);
    %resp(:,nROI) = [mean(s(1:19,55:65),2);mean(s(21:40,115:125),2)];
    resp(nROI,:) = mean(s);
    m = createMask(hEl(nROI));
    mCh(nROI) = mean(mean(double(stimExpt.StimROIs.imData(:,:,2).*m)));
    mGC(nROI) = mean(mean(double(stimExpt.StimROIs.imData(:,:,1).*m)));
end

pk = mean(resp(:,118:125),2);
figure,plot(resp')
figure,plot(mCh,pk,'.')
figure,plot(mGC,pk,'.')
figure,plot(mCh,mGC,'.')

%% Selection
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
nROI = 1;
nTarg = nROI;
x = (-29:300)/30;
sel = (tMax|tMed) & tV.nTarg == nTarg & tV.nRepeat < 21;
s = getTrigStim(dF,tV,sel,nROI,0,1);
%figure,imagesc(s)
figure,plot(x,mean(s),'k'),
hold on,plot(x,median(matConv(s,3)),'r','linewidth',2)
plot(x,mean(matConv(s,3)),'g','linewidth',2)
axis tight,

%% Automation
resp = [];
for nROI = 1:21
    nTarg = nROI;
    sel = (tMax|tMed) & tV.nTarg == nTarg & tV.nRepeat <= 5;
    s = getTrigStim(dF,tV,sel,nROI,0);
    %resp(:,nROI) = [mean(s(1:19,55:65),2);mean(s(21:40,115:125),2)];
    resp(nROI,:) = mean(s);
    m = createMask(hEl(nROI));
    mCh(nROI) = mean(mean(double(stimExpt.StimROIs.imData(:,:,2).*m)));
end

pk = mean(resp(:,58:65),2);

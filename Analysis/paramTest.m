% %% Choose nTarg and nROI
% nTarg = 16;
% nROI = 10;
for iROI = 1:15
    for iTarg = 1:20
        sel = tV.nTarg == iTarg;
        sMat(iROI,iTarg,:) = median(getTrigStim(nT,tV,sel,iROI,0));
    end
end

figure, imagesc(mean(sMat(:,:,37:45),3))

%% Trial Parameter Selectors
t30 = tV.dur == 30e-3;
tH = tV.pockPow == 1.5;
tN = tV.pockPulseFreq == 0;
tT = tV.nStim > 1;
tR = tV.nTarg == nTarg;

%% Average over single stim and train
sel = tR & t30 & tH & tN;
s = getTrigStim(nT,tV,sel,nROI,0);
sel = tR & ~t30 & tH & tN;
s15 = getTrigStim(nT,tV,sel,nROI,0);
sel = tR & t30 & ~tH & tN;
sL = getTrigStim(nT,tV,sel,nROI,0);
sel = tR & t30 & tH & ~tN;
sP = getTrigStim(nT,tV,sel,nROI,0);
figure,hold on,plot(median(s))
plot(median(s15))
plot(median(sL))
plot(median(sP))

%% Average over trains only
sel = tR & t30 & tH & tN & tT;
s = getTrigStim(nT,tV,sel,nROI,0);
sel = tR & ~t30 & tH & tN & tT;
s15 = getTrigStim(nT,tV,sel,nROI,0);
sel = tR & t30 & ~tH & tN & tT;
sL = getTrigStim(nT,tV,sel,nROI,0);
sel = tR & t30 & tH & ~tN & tT;
sP = getTrigStim(nT,tV,sel,nROI,0);
figure,hold on,plot(median(s))
plot(median(s15))
plot(median(sL))
plot(median(sP))

%% Average over single stim only
sel = tR & t30 & tH & tN & ~tT;
s = getTrigStim(nT,tV,sel,nROI,0);
sel = tR & ~t30 & tH & tN & ~tT;
s15 = getTrigStim(nT,tV,sel,nROI,0);
sel = tR & t30 & ~tH & tN & ~tT;
sL = getTrigStim(nT,tV,sel,nROI,0);
sel = tR & t30 & tH & ~tN & ~tT;
sP = getTrigStim(nT,tV,sel,nROI,0);
figure,hold on,plot(median(s))
plot(median(s15))
plot(median(sL))
plot(median(sP))
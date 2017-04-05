function [] = dispStimPair(stimExpt,nROI,nTarg)

if nargin<3
    nTarg = nROI;
end

sel = stimExpt.tV.nTarg == nTarg;
x = (-89:150)/30;
s = getTrigStim(stimExpt.dF,stimExpt.tV,sel,nROI);
sD = nan(size(s));
c = jet(size(s,1));
figure(1),clf, hold on
for i=1:size(s,1)
    plot(x,s(i,:),'color',c(i,:))
end
plot(x,nanmean(s),'k','linewidth',2)
axis tight
stimOnsets = cellfun(@min, stimExpt.tV.stimFrames(sel));
X = -89:150;
for stimTrial = 1:length(stimOnsets)
    stimOnset = stimOnsets(stimTrial);
    if stimOnset + min(X) > 0
        sD(stimTrial,:) = stimExpt.de(nROI,stimOnset+X);
    else
        offset = stimOnset + min(X) - 1;
        sD(stimTrial,1-offset:end) = stimExpt.de(nROI,stimOnset + X(1-offset:end));
    end
end
sD = sD * 30;
figure(2),clf,imagesc(x,1:size(sD,1),matConv(sD,2))
figure(3),clf,plot(x,mean(sD),'k'),
hold on,plot(x,median(matConv(sD,2)),'r','linewidth',2)
% plot(x,mean(matConv(sD,2)),'g','linewidth',2)
axis tight,

figure(4),clf
plot(stimExpt.dF(nROI,:),'k'),hold on,
for trial = find(sel)
    stimFrame = stimExpt.tV.stimFrames{trial}(1);
    plot(stimFrame+10,stimExpt.dF(nROI,stimFrame+10),'r*','markersize',10),
end
sel = (1) & tV.nTarg == nTarg;
x = (-299:300)/30;
s = getTrigStim(dF,tV,sel,nROI,0,0);
c = jet(size(s,1));
figure(1),clf, hold on
for i=1:size(s,1)
    plot(x,s(i,:),'color',c(i,:))
end
plot(x,nanmean(s),'k','linewidth',2)
axis tight
stimOnsets = cellfun(@min, tV.stimFrames(sel));
X = -299:300;
for stimTrial = 1:length(stimOnsets)
    stimOnset = stimOnsets(stimTrial);
    if stimOnset + min(X) > 0
        sD(stimTrial,:) = de(nROI,stimOnset+X);
    else
        offset = stimOnset + min(X) - 1;
        sD(stimTrial,1-offset:end) = de(nROI,stimOnset + X(1-offset:end));
    end
end
sD = sD * 30;
%sD = getTrigStim(dF,tV,sel,nROI,0,1) * 30;
figure(2),clf,imagesc(x,1:size(sD,1),matConv(sD,2))
figure(3),clf,plot(x,mean(sD),'k'),
hold on,plot(x,median(matConv(sD,2)),'r','linewidth',2)
plot(x,mean(matConv(sD,2)),'g','linewidth',2)
axis tight,

figure(4),clf
cMap = flipud(parula(6));
%trialConds = cat(1,t3,t6,t9,t13);
%trialConds = cat(1,t2,t4,t8,t16);
plot(dF(nROI,:),'k'),hold on,
allSel = tV.nTarg == nTarg;
% for trial = find(allSel)
%     stimFrame = tV.stimFrames{trial}(1);
%     trialCond = find(trialConds(:,trial))+1;
%     plot(stimFrame+15,dF(nROI,stimFrame+15),'.','markersize',25,...
%         'color',cMap(trialCond,:)),
% end
for trial = find(sel)
    stimFrame = tV.stimFrames{trial}(1);
    plot(stimFrame+10,dF(nROI,stimFrame+10),'r*','markersize',10),
end
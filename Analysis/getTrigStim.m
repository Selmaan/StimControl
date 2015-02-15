function sEns = getTrigStim(dF, trialVec, selectionVec, nROI, showFig, deConv)

if nargin < 5
    showFig = 1;
    deConv = 0;
end

if nargin < 6
    deConv = 0;
end

if deConv == 0
    X = -299:300;
    sig = dF(nROI,:);
else 
    X = -299:300;
    sig = getDeconv(dF(nROI,:));
end

nTrials = sum(selectionVec);
f = trialVec.stimFrames(selectionVec);
sEns=nan(nTrials,length(X));
for i=1:nTrials
    sEns(i,:) = sig(f{i}(1) + X);
end

if deConv == 0
    ind = find(X>-11 & X<0);
    sEns = bsxfun(@minus,sEns,mean(sEns(:,ind),2));
end

if showFig
    figure,plot(X/30,sEns'),
    hold on,
    plot(X/30,mean(sEns),'k','linewidth',2),
end
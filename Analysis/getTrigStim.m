function sEns = getTrigStim(dF, trialVec, selectionVec, nROI, showFig)

if nargin < 5
    showFig = 1;
end

X = -29:90;

f = trialVec.stimFrames(selectionVec);
sEns=nan(length(f),120);
for i=1:length(f)
    sEns(i,:) = dF(nROI,f(i)+X);
end

sEns = bsxfun(@minus,sEns,mean(sEns(:,15:25),2));

if showFig
    figure,plot(X/30,sEns'),
    hold on,
    plot(X/30,mean(sEns),'k','linewidth',2),
end
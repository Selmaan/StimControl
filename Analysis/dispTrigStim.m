function sEns = dispTrigStim(dF, trialVec, selectionVec, showFig)

if nargin < 4
    showFig = 1;
end

Y = 1:size(dF,1);
X = -29:90;

f = trialVec.stimFrames(selectionVec);
sEns=nan(size(dF,1),120,length(f));
for i=1:length(f)
    sEns(:,:,i) = dF(:,f(i)+X);
end

sEns = bsxfun(@minus,mean(sEns,3),mean(mean(sEns(:,15:25,:),3),2));

if showFig
    figure,imagesc(X/30,Y,sEns),
    colorbar,
end
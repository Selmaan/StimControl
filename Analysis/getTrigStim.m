function sEns = getTrigStim(dF, trialVec, selectionVec, nROI, showFig, deConv)

if nargin < 5
    showFig = 1;
    deConv = 0;
end

if nargin < 6
    deConv = 0;
end

if deConv == 0
    X = -240:300;
    sig = dF(nROI,:);
else 
    X = -240:300;
    sig = getDeconv(dF(nROI,:));
end

nTrials = sum(selectionVec);
f = trialVec.stimFrames(selectionVec);
sEns=nan(nTrials,length(X));
for i=1:nTrials
    if f{i}(1) + min(X) > 0
        sEns(i,:) = sig(f{i}(1) + X);
    else
        offset = f{i}(1) + min(X) - 1;
        sEns(i,1-offset:end) = sig(f{i}(1) + X(1-offset:end));
    end
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
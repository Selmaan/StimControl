function sEns = getTrigStim(dF, trialVec, selectionVec, nROI)

X = -89:150;
sig = dF(nROI,:);

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

ind = find(X>-11 & X<0);
sEns = bsxfun(@minus,sEns,mean(sEns(:,ind),2));

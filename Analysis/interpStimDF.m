
dF(:,exF) = nan;
interpDenom = stimFrameDur + 1;
for i=exF
    if isnan(dF(1,i))
        stimOn = i;
        stimOff = stimOn + stimFrameDur;
        preVals = dF(:,stimOn-1);
        postVals = dF(:,stimOff);
        for frameInd = 1:stimFrameDur
            dF(:,stimOn+frameInd-1) = (interpDenom-frameInd)/interpDenom * preVals ...
                + frameInd/interpDenom * postVals;
        end
    end
end
function allResp = randomGratingsRespStruct(stimExpt)


gratingBlocks = find(~stimExpt.stimBlocks);
for nBlock = gratingBlocks
    Dir = stimExpt.stimInfo{nBlock}(6:6:end);
    SF = stimExpt.stimInfo{nBlock}(7:6:end);
    TF = stimExpt.stimInfo{nBlock}(8:6:end);
    CT = stimExpt.stimInfo{nBlock}(9:6:end);
    
    fSpd = sqrt(sum(stimExpt.ballVel{nBlock}.^2,2));
    
    f2p = interp1(stimExpt.psychTimes{nBlock},...
        1:length(stimExpt.psychTimes{nBlock}),stimExpt.frameTimes{nBlock},'nearest');
    f2p_valid = find(~isnan(f2p));
    fCT = nan(length(stimExpt.frameTimes{nBlock}),1);
    fDir(f2p_valid) = Dir(f2p(f2p_valid));
    fSF(f2p_valid) = log2(SF(f2p(f2p_valid)));
    fTF(f2p_valid) = log2(TF(f2p(f2p_valid)));
    fCT(f2p_valid) = CT(f2p(f2p_valid));
    smCT = conv(fCT,gausswin(15)/sum(gausswin(15)),'same');
    ctTrig = 1+find(diff(smCT(2:end))>0 & diff(smCT(1:end-1)) < 0);
    blockOffsetFrame = length(cat(1,stimExpt.frameTimes{1:nBlock-1}));
    traces = stimExpt.dF_deconv(:,blockOffsetFrame+1:blockOffsetFrame+length(stimExpt.frameTimes{nBlock}));
    cycleDur = mode(diff(ctTrig));
    allResp.yPh{nBlock} = zeros(size(traces,1),cycleDur);
    fprintf('Block %d had %d cycles at %d frames-per-cycle \n',nBlock,length(ctTrig)-1,cycleDur);
    for nCycle = 1:length(ctTrig)-1
        cycleInd = ctTrig(nCycle) + (1:cycleDur);
        allResp.Y{nBlock}(:,nCycle) = mean(traces(:,cycleInd),2);
        allResp.yPh{nBlock} = allResp.yPh{nBlock} + traces(:,cycleInd)/length(ctTrig);
        allResp.Dir{nBlock}(nCycle) = mode(fDir(cycleInd));
        allResp.SF{nBlock}(nCycle) = mode(fSF(cycleInd));
        allResp.TF{nBlock}(nCycle) = mode(fTF(cycleInd));
        allResp.spd{nBlock}(nCycle) = mean(fSpd(cycleInd));
    end
end

allResp.Y = cat(2,allResp.Y{:})';
allResp.yPh = mean(cat(3,allResp.yPh{:}),3)';
allResp.Dir = cat(2,allResp.Dir{:})';
allResp.SF = cat(2,allResp.SF{:})';
allResp.TF = cat(2,allResp.TF{:})';
allResp.spd = cat(2,allResp.spd{:})';
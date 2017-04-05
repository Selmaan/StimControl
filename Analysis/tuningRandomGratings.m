stimExpt = resFOV1.syncInfo.stimExpt;
tmp.f2p = interp1(stimExpt.psychTimes{1},...
    1:length(stimExpt.psychTimes{1}),stimExpt.frameTimes{1},'nearest');
tmp.f2p_on = find(~isnan(tmp.f2p),1,'first');
tmp.f2p_off = find(~isnan(tmp.f2p),1,'last');

tmp.gratingBlocks = find(~stimExpt.stimBlocks);
for nBlock = tmp.gratingBlocks
    tmp.Dir = stimExpt.stimInfo{nBlock}(6:6:end);
    tmp.SF = stimExpt.stimInfo{nBlock}(7:6:end);
    tmp.TF = stimExpt.stimInfo{nBlock}(8:6:end)./tmp.SF;
    tmp.
    
    
tmp.SF = stimExpt.stimInfo{1}(7:6:end);
tmp.fSF = tmp.SF(tmp.f2p(300:end));
tmp.fSF = log2(tmp.fSF);


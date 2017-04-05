%%
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
    tmp.CT = stimExpt.stimInfo{nBlock}(9:6:end);
end
        
tmp.fSF = log2(tmp.SF(tmp.f2p(tmp.f2p_on:tmp.f2p_off)));
tmp.fTF = log2(tmp.TF(tmp.f2p(tmp.f2p_on:tmp.f2p_off)));
tmp.fCT = log2(tmp.CT(tmp.f2p(tmp.f2p_on:tmp.f2p_off)));

%% randomGratings protocol info

% bootup write:
fwrite(fID,[contrastSpeed, tempFreqs(1), tempFreqs(2), spatialFreqs(1), spatialFreqs(2)],'float64');
% Frame-wise write:
fwrite(fID,[thisAngle, thisSpaceFreq, thisSpeed, thisContrast, xoffset, vbl],'float64');


%%
tmp = struct;

tmp.gratingBlocks = find(~stimExpt.stimBlocks);
tmp.Traces = [];
for nBlock = tmp.gratingBlocks
    tmp.Dir = stimExpt.stimInfo{nBlock}(6:6:end);
    tmp.SF = stimExpt.stimInfo{nBlock}(7:6:end);
%     tmp.TF = stimExpt.stimInfo{nBlock}(8:6:end)./tmp.SF;
    tmp.TF = stimExpt.stimInfo{nBlock}(8:6:end);
    tmp.CT = stimExpt.stimInfo{nBlock}(9:6:end);
    
    tmp.f2p = interp1(stimExpt.psychTimes{nBlock},...
        1:length(stimExpt.psychTimes{nBlock}),stimExpt.frameTimes{nBlock},'nearest');
    tmp.f2p_valid = find(~isnan(tmp.f2p));
    tmp.fDir{nBlock} = nan(length(stimExpt.frameTimes{nBlock}),1);
    tmp.fSF{nBlock} = nan(length(stimExpt.frameTimes{nBlock}),1);
    tmp.fTF{nBlock} = nan(length(stimExpt.frameTimes{nBlock}),1);
    tmp.fCT{nBlock} = nan(length(stimExpt.frameTimes{nBlock}),1);
    tmp.fDir{nBlock}(tmp.f2p_valid) = tmp.Dir(tmp.f2p(tmp.f2p_valid));
    tmp.fSF{nBlock}(tmp.f2p_valid) = log2(tmp.SF(tmp.f2p(tmp.f2p_valid)));
    tmp.fTF{nBlock}(tmp.f2p_valid) = log2(tmp.TF(tmp.f2p(tmp.f2p_valid)));
    tmp.fCT{nBlock}(tmp.f2p_valid) = tmp.CT(tmp.f2p(tmp.f2p_valid));
    tmp.blockOffsetFrame = length(cat(1,stimExpt.frameTimes{1:nBlock-1}));
    tmp.Traces = cat(2,tmp.Traces,stimExpt.dF_deconv...
        (:,tmp.blockOffsetFrame+1:tmp.blockOffsetFrame+length(stimExpt.frameTimes{nBlock})));
end

tmp.Traces = matConv(tmp.Traces,3);
tmp.naiveCorr = corr(tmp.Traces',tmp.Traces(stimExpt.cellStimInd,:)');

%% Make GLM Predictor Matrices
nDir = 18;
nSF = 8;
nTF = 8;
n

%%
distThresh = 30;
[nRespMat, visResid, deResp, stimID, visOri, visCon, stimMag] =...
    calcStimShuffle(stimExpt, distThresh);
[coefs,fits,deResp,stimID,visOri,visCon] = makeStimGLMs(stimExpt, distThresh);
%%
stimThresh = 0.2;
stimDistThresh = 8;

% validResp = nRespMat;
validResp = coefs(:,1:length(stimMag));
for i=1:size(validResp,2)
    if stimMag(i)<stimThresh || stimExpt.cellStimDist(i)>stimDistThresh
        validResp(:,i) = nan;
    end
end
%%
tmp.dBinWidth = 100;
tmp.Dist = stimExpt.cellStimDistMat*stimExpt.xConvFactor;
infDistBin = nan(500,1);
infDistCorBin = nan(500,1);
for d=1:500
    tmp.thesePairs = tmp.Dist<d+tmp.dBinWidth & tmp.Dist>d;
    tmp.theseVals = validResp(tmp.thesePairs);
    tmp.invalidPairs = isnan(tmp.theseVals);
    tmp.theseVals(tmp.invalidPairs)=[];
    tmp.theseCorr = tmp.naiveCorr(tmp.thesePairs);
    tmp.theseCorr(tmp.invalidPairs) = [];
    infDistBin(d) = trimmean(tmp.theseVals,0);
    infDistCorBin(d) = corr(tmp.theseCorr,tmp.theseVals,'type','Spearman');
end

%% randomGratings protocol info

% bootup write:
fwrite(fID,[contrastSpeed, tempFreqs(1), tempFreqs(2), spatialFreqs(1), spatialFreqs(2)],'float64');
% Frame-wise write:
fwrite(fID,[thisAngle, thisSpaceFreq, thisSpeed, thisContrast, xoffset, vbl],'float64');



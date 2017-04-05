function stimExpt = calcRespProps(stimExpt,respFrames)

if nargin<2
    respFrames = 0:11;
end

tV = stimExpt.tV;
de = stimExpt.de;

pkStim = nan(max(tV.nTarg),size(de,1),length(tV.nTarg)/max(tV.nTarg));
for nTarg = unique(tV.nTarg)
    sel = tV.nTarg == nTarg;
    stimOnsets = cellfun(@min, tV.stimFrames(sel));
%     stimOffsets = cellfun(@max, tV.stimFrames(sel));
        for stimTrial = 1:length(stimOnsets)
            stimOnset = stimOnsets(stimTrial);
%             stimOffset = stimOffsets(stimTrial);
            pkStim(nTarg,:,stimTrial) = mean(de(:,stimOnset + respFrames),2);
        end
end

repStim = [];
for nRep = 1:size(pkStim,3)
    repStim(:,nRep) = diag(pkStim(:,:,nRep));
end
respMat = mean(pkStim,3);

stimExpt.pkStim = pkStim;
stimExpt.repStim = repStim;
stimExpt.respMat = respMat;
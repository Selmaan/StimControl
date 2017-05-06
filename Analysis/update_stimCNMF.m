function update_stimCNMF(acqObj)

stimExpt = acqObj.syncInfo.stimExpt;
cd(acqObj.defaultDir),

%% Identify cells and other potential stim-sources and get traces

% Manually verify stimulation targets
[targetID,targetLabel] = confirmStimTargets(stimExpt,acqObj);
stimExpt.stimSources = targetID';
stimExpt.targetLabel = targetLabel';

A = load(acqObj.roiInfo.slice.NMF.filename,'A');
A = A.A;
l = clusterSourcesWithCurrentNn(A);
cellSources = find(l==1);
validSources{1} = [stimExpt.stimSources(targetLabel>=1);...
    setdiff(cellSources,stimExpt.stimSources(targetLabel>=1))];

stimFrames = cell(0);
for nBlock = find(stimExpt.stimBlocks)
    blockOffsetFrame = length(cat(1,stimExpt.frameTimes{1:nBlock-1}));
    stimFrames{nBlock} = blockOffsetFrame + stimExpt.psych2frame{nBlock}(1:length(stimExpt.stimOrder{nBlock}));
end

stimFrames = cat(1,stimFrames{stimExpt.stimBlocks});
stimFrames = repmat(stimFrames,1,4) + repmat(0:2:6,size(stimFrames,1),1);
stimFrames = stimFrames(:);
interpFrames = cell(0);
interpFrames{1} = stimFrames;
interpFrames{2} = stimFrames+1;
interpFrames{3} = stimFrames-1;

[dF,deconv,denoised,Gs,Lams,A,b,f] = extractTraces_NMF(acqObj,validSources,interpFrames);
dF = cell2mat(dF);
A = cell2mat(A);
denoised = cell2mat(denoised);
deconv = cell2mat(deconv);
%% 

cellFilts = bsxfun(@rdivide,A,sum(A,1));
[i,j] = ind2sub([512,512],1:512^2);
cellCentroids = ([j;i]*cellFilts)';
[xWorld,yWorld] = intrinsicToWorld(stimExpt.resRA,...
    cellCentroids(:,1),cellCentroids(:,2));
cellCentroids = [xWorld,yWorld];
nStim = size(stimExpt.roiCentroid,1);
nCell = size(cellCentroids,1);
distMat = sqrt(sum((repmat(reshape(cellCentroids,nCell,1,2),[1 nStim 1]) -...
    repmat(reshape(stimExpt.roiCentroid,1,nStim,2),[nCell 1 1])).^2,3));

stimExpt.dF_deconv = deconv;
stimExpt.dF = dF;
stimExpt.cIds = validSources{1};
stimExpt.cellFilts = cellFilts;
stimExpt.cellStimDistMat = distMat;
stimExpt.cellCentroids = cellCentroids;

tmpDir = acqObj.defaultDir;
expName = strrep(tmpDir(end-10:end-1),'\','_');
for i=1:length(stimExpt.syncFns)
    stimExpt.stimFns{i} = fullfile(acqObj.defaultDir,sprintf('%s_%d',expName,i));
    stimFID = fopen(stimExpt.stimFns{i});
    stimExpt.stimInfo{i} = fread(stimFID,'float64');
    fclose(stimFID);
end

save('stimExpt','stimExpt'),
acqObj.syncInfo.stimExpt = stimExpt;
acqObj.save,
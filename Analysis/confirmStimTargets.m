function [targetID,targetLabel] = confirmStimTargets(stimExpt,acqObj,idExp)

%%
% Code for confirmation numbers is
% -2: reset selection
% -1: choose next closest source
% 0: No source, no response
% 0.1: No source, response
% 1: Source, response
% 1.1: Source, no response
% 1.2: Merged or Split Source, response

%% inputs
fprintf('Loading Data...'),
A = load(acqObj.roiInfo.slice.NMF.filename,'A');
A = A.A;
Cf = load(acqObj.roiInfo.slice.NMF.traceFn,'Cf');
Cf = Cf.Cf;
fprintf('Done! \n'),

%% Get Stimulation Frames for all Targets

nTargs = length(unique(stimExpt.stimOrder{find(stimExpt.stimBlocks,1)}));
allStim = cell(nTargs,1);

for nBlock = find(stimExpt.stimBlocks)
    for nTarg = 1:nTargs
        blockOffsetFrame = length(cat(1,stimExpt.frameTimes{1:nBlock-1}));
        theseStim = blockOffsetFrame+stimExpt.psych2frame{nBlock}(stimExpt.stimOrder{nBlock}==nTarg);
        allStim{nTarg} = [allStim{nTarg};theseStim];
    end
end

%%
if ~exist('idExp','var') || isempty(idExp)
    idExp = 1:nTargs;
    fprintf('Confirming Targets 1 through %d \n',nTargs),
else
    fprintf('Confirming Targets %d through %d \n',min(idExp),max(idExp)),
end
stimTargets = struct;
% idExp = input('Input vector of expressing-target numbers: ');
idNonExp = setdiff(1:nTargs,idExp);


%% Get source centroids and source-target distance matrix

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
distMat = distMat * (stimExpt.xConvFactor/2 + stimExpt.yConvFactor/2);
[mDistVal,mDistInd] = min(distMat);

%% 

distThresh = 15;
for nTarget = idExp
    stimFrames = allStim{nTarget}(:);
    nonFrames = cat(1,allStim{setdiff(1:nTargs,nTarget)});
    stimFrames = bsxfun(@plus,stimFrames,-30:180);
    nonFrames = bsxfun(@plus,nonFrames,-30:180);
    nearSources = find(distMat(:,nTarget)<distThresh);
    thisSource =  mDistInd(nTarget);
    if isempty(nearSources)
       nearSources = thisSource;
    end    
    sourceAccepted = false;
    tmpDist = distMat;

    while ~sourceAccepted
        plotSourceTarget(stimExpt,stimFrames,...
            nonFrames,nTarget,thisSource,nearSources,Cf,cellFilts);
        commandwindow,
        respFlag = input(sprintf('Accept Source %d? ',nTarget));
        if respFlag >= 0
            sourceAccepted = true;
        elseif respFlag == -1
            tmpDist(thisSource,:) = inf;
        else
            tmpDist = distMat;
        end
        nearSources = find(tmpDist(:,nTarget)<distThresh);
        [~,thisSource] =  min(tmpDist(:,nTarget));
        if isempty(thisSource) || isempty(nearSources)
            tmpDist = distMat;
            thisSource = mDistInd(nTarget);
            nearSources = thisSource;
        end
    end
    targetLabel(nTarget) = respFlag;
    if respFlag >= 1
        targetID(nTarget) = thisSource;
    else
        targetID(nTarget) = nan;
    end
end

targetLabel(idNonExp) = 0;
targetID(idNonExp) = nan;
end

function plotSourceTarget(stimExpt,stimFrames,...
    nonFrames,nTarget,thisSource,nearSources,Cf,cellFilts)
    
    stimTraces = reshape(Cf(thisSource,stimFrames(:)),[],211);
    theseTraces = [median(stimTraces); mean(stimTraces)];
    nonTraces = reshape(Cf(thisSource,nonFrames(:)),[],211);
    theseTraces(3:4,:) = [median(nonTraces); mean(nonTraces)];
    theseTraces = theseTraces/prctile(theseTraces(:),10);
    figure(638),
    plot((-30:180)/30,theseTraces([3,1,2,4],:)','linewidth',2),
    axis tight,
    
    [colIntrinsic,rowIntrinsic] = worldToSubscript(stimExpt.resRA,...
        stimExpt.roiCentroid(nTarget,1),stimExpt.roiCentroid(nTarget,2));
    thisFilt = cellFilts(:,thisSource)*2;
    thisFilt = 2*thisFilt/max(thisFilt);
    nearFilts = sum(cellFilts(:,setdiff(nearSources,thisSource)),2);
    nearFilts = 2*nearFilts/max(nearFilts);
%     allNearFilts = cellFilts(:,setdiff(nearSources,thisSource));
%     nearFilts = sum(bsxfun(@rdivide,2*allNearFilts,max(allNearFilts)),2);
    stimRef = stimExpt.procStimIm(:,:,nTarget);
    stimRef = 2*stimRef/max(stimRef(:));
    imFilt = reshape(full([thisFilt, nearFilts, stimRef(:)]),512,512,3);
    figure(639),
    imshow(imresize(imFilt((-20:20)+colIntrinsic,(-20:20)+rowIntrinsic,:),10)),
    
    [linColInt,linRowInt] = worldToSubscript(stimExpt.linRA,...
        stimExpt.roiCentroid(nTarget,1),stimExpt.roiCentroid(nTarget,2));
    figure(640),
    linColVals = min(max((-20:20)+linColInt,1),512);
    linRowVals = min(max((-20:20)+linRowInt,1),512);
    imshow(imresize(stimExpt.rLin(linColVals,linRowVals)/600-.2,10)),
    
end
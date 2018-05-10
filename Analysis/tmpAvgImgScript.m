winRad = 15;
winDiam = 2*winRad+1;
stimIm = zeros(winDiam,winDiam);
[yInd,xInd] = stimExpt.resRA.worldToSubscript(stimExpt.cellCentroids(:,1),stimExpt.cellCentroids(:,2));
yInd = yInd+winRad; xInd = xInd+winRad;
distBin = tmp.Dist<300 & tmp.Dist>25;
refIm = bsxfun(@rdivide,stimExpt.rawStimIm,meanRef(resFOV1));

for nStim = 1:size(validResp,2)
    thisStimIm = padarray(refIm(:,:,nStim),[winRad winRad],0);
    for nResp = 1:size(validResp,1)
        if distBin(nResp,nStim) && ~isnan(validResp(nResp,nStim))
            xRange = xInd(nResp)-winRad:xInd(nResp)+winRad;
            yRange = yInd(nResp)-winRad:yInd(nResp)+winRad;
            thisIm = thisStimIm(yRange,xRange);
            thisIm(isnan(thisIm)) = 0;
%             stimIm = stimIm + thisIm/mad(thisIm(:));
            stimIm = stimIm + thisIm;
        end
    end
end

stimIm = stimIm / sum(~isnan(validResp(distBin)));
figure,imagesc(stimIm),colorbar,


%%
clear,
thisSession = v1inf.Experiment & 'exp_date="2017-12-19"';
thisInfluence = (v1inf.Influence & thisSession) & 'inf_dist>25';

% Get Data
allTargets = v1inf.Target & thisSession;
pairLoc = proj(thisInfluence) * v1inf.Neuron;
[xLoc,yLoc,tID] = fetchn(pairLoc,'neur_xc','neur_yc','targ_id');
targInfo = fetch(allTargets,'targ_id','targ_rawim',...
    'targ_label','ORDER BY targ_id');
STAs = cat(3,targInfo.targ_rawim)./fetch1(v1inf.MeanRefImg & thisSession,'mean_ref');
STAs(~isfinite(STAs)) = 0;

% Convert centroids to subscripts
% stimImgRA = imref2d([512 512],[-7.8 7.8],[-7.8 7.8]);
% centroidsWorld = [xLoc,yLoc] / 39.1933;
% [yInd, xInd] = stimImgRA.worldToSubscript(centroidsWorld(:,1),centroidsWorld(:,2));
yInd = round(256.5 + 0.8373 * yLoc);
xInd = round(256.5 + 0.8373 * xLoc);

% Construct valid and control images
validTarg = find([targInfo.targ_label]>0.99);
controlTarg = find([targInfo.targ_label]<0.01);
winRad = 20;
stimImV = zeros(winRad*2+1);
stimImC = zeros(winRad*2+1);
for i = 1:length(tID)
    xRange = xInd(i)-winRad : xInd(i)+winRad;
    xRange(xRange<1)=1; xRange(xRange>512)=512;
    yRange = yInd(i)-winRad : yInd(i)+winRad;
    yRange(yRange<1)=1; yRange(yRange>512)=512;
    thisStimIm = STAs(yRange,xRange,tID(i));
    
    if ismember(tID(i),validTarg)
        stimImV = stimImV + thisStimIm;
    elseif ismember(tID(i),controlTarg)
        stimImC = stimImC + thisStimIm;
    end
end

stimImV = stimImV / sum(ismember(tID,validTarg));
stimImC = stimImC / sum(ismember(tID,controlTarg));
figure,subplot(1,2,1),imagesc(stimImV),colorbar,axis square,title('Valid Targets'),
subplot(1,2,2),imagesc(stimImC),colorbar,axis square,title('Control Targets'),
        
%% Average over multiple sessions

clear,
allSessions = fetch(v1inf.Experiment & 'mouse_id=37');
winRad = 20;

stimImV = zeros(winRad*2+1);
stimImC = zeros(winRad*2+1);
vCount = 0;
cCount = 0;
for iSession = 1:length(allSessions)
    iSession,
    thisSession = v1inf.Experiment & allSessions(iSession);
    thisInfluence = (v1inf.Influence & thisSession) & 'inf_dist>25';
%     thisInfluence = (v1inf.Influence & thisSession) & 'inf_dist>25' & 'inf_shuf_n<-2.5' & 'inf_shuf_n>-3.5';

    % Get Data
    allTargets = v1inf.Target & thisSession;
    pairLoc = proj(thisInfluence) * v1inf.Neuron;
    [xLoc,yLoc,tID] = fetchn(pairLoc,'neur_xc','neur_yc','targ_id');
    targInfo = fetch(allTargets,'targ_id','targ_rawim',...
        'targ_label','ORDER BY targ_id');
    STAs = cat(3,targInfo.targ_rawim)./fetch1(v1inf.MeanRefImg & thisSession,'mean_ref');
    STAs(~isfinite(STAs)) = 0;

    % Convert centroids to subscripts
    % stimImgRA = imref2d([512 512],[-7.8 7.8],[-7.8 7.8]);
    % centroidsWorld = [xLoc,yLoc] / 39.1933;
    % [yInd, xInd] = stimImgRA.worldToSubscript(centroidsWorld(:,1),centroidsWorld(:,2));
    yInd = round(256.5 + 0.8373 * yLoc);
    xInd = round(256.5 + 0.8373 * xLoc);

    % Construct valid and control images
    validTarg = find([targInfo.targ_label]>0.99);
    controlTarg = find([targInfo.targ_label]<0.01);
    
    for i = 1:length(tID)
        xRange = xInd(i)-winRad : xInd(i)+winRad;
        xRange(xRange<1)=1; xRange(xRange>512)=512;
        yRange = yInd(i)-winRad : yInd(i)+winRad;
        yRange(yRange<1)=1; yRange(yRange>512)=512;
        thisStimIm = STAs(yRange,xRange,tID(i));

        if ismember(tID(i),validTarg)
            stimImV = stimImV + thisStimIm;
        elseif ismember(tID(i),controlTarg)
            stimImC = stimImC + thisStimIm;
        end
    end
    
    vCount = vCount + sum(ismember(tID,validTarg));
    cCount = cCount + sum(ismember(tID,controlTarg));

end

stimImV = stimImV / vCount;
stimImC = stimImC / cCount;
figure,subplot(1,2,1),imagesc(stimImV),colorbar,axis square,title('Valid Targets'),
subplot(1,2,2),imagesc(stimImC),colorbar,axis square,title('Control Targets'),

%% Target-Location Stimulation
clear,
thisSession = v1inf.Experiment & 'exp_date="2017-12-13"';

% Get Data
allTargets = v1inf.Target & thisSession;
[xLoc,yLoc,tID] = fetchn(allTargets,'targ_xc','targ_yc','targ_id');
targInfo = fetch(allTargets,'targ_id','targ_rawim',...
    'targ_label','ORDER BY targ_id');
STAs = cat(3,targInfo.targ_rawim)./fetch1(v1inf.MeanRefImg & thisSession,'mean_ref');
STAs(~isfinite(STAs)) = 0;

% Convert centroids to subscripts
% stimImgRA = imref2d([512 512],[-7.8 7.8],[-7.8 7.8]);
% centroidsWorld = [xLoc,yLoc] / 39.1933;
% [yInd, xInd] = stimImgRA.worldToSubscript(centroidsWorld(:,1),centroidsWorld(:,2));
yInd = round(256.5 + 0.8373 * yLoc);
xInd = round(256.5 + 0.8373 * xLoc);

% Construct valid and control images
validTarg = find([targInfo.targ_label]>0.99);
controlTarg = find([targInfo.targ_label]<0.01);
winRad = 20;
stimImV = zeros(winRad*2+1);
stimImC = zeros(winRad*2+1);
for i = 1:length(tID)
    xRange = xInd(i)-winRad : xInd(i)+winRad;
    xRange(xRange<1)=1; xRange(xRange>512)=512;
    yRange = yInd(i)-winRad : yInd(i)+winRad;
    yRange(yRange<1)=1; yRange(yRange>512)=512;
    thisStimIm = STAs(yRange,xRange,tID(i));
    
    if ismember(tID(i),validTarg)
        stimImV = stimImV + thisStimIm;
    elseif ismember(tID(i),controlTarg)
        stimImC = stimImC + thisStimIm;
    end
end

stimImV = stimImV / sum(ismember(tID,validTarg));
stimImC = stimImC / sum(ismember(tID,controlTarg));
figure,subplot(1,2,1),imagesc(stimImV),colorbar,axis square,title('Valid Targets'),
subplot(1,2,2),imagesc(stimImC),colorbar,axis square,title('Control Targets'),
        
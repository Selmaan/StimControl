
%% Inputs
tempFreqs = 2.^[-1 2];
spatialFreqs = 2.^[-2 2]; %1 is normalized to ~.04 cyc/degree
contrastSpeed = 1/4;
apertureStd = 600;

%%
tmp = struct;

tmp.gratingBlocks = find(~stimExpt.stimBlocks);
for nBlock = tmp.gratingBlocks
    tmp.Dir = stimExpt.stimInfo{nBlock}(6:6:end);
    tmp.SF = stimExpt.stimInfo{nBlock}(7:6:end);
    tmp.TF = stimExpt.stimInfo{nBlock}(8:6:end);
    tmp.CT = stimExpt.stimInfo{nBlock}(9:6:end);
    tmp.Ph = stimExpt.stimInfo{nBlock}(10:6:end);
    
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
    tmp.fPh{nBlock}(tmp.f2p_valid) = tmp.Ph(tmp.f2p(tmp.f2p_valid));

end


%%
pixPerCm = 35;
cmToScreen = 22;
baseGratingCm = tand(12.5)*cmToScreen*2; %Approx 25deg (.04 SF) as two 12.5deg triangles
p = round(pixPerCm * baseGratingCm); % Approx pixels per cycle using .04SF
% Also need frequency in radians:
fr=1/p*2*pi;
gratingsize = (1+max(spatialFreqs))*1920;
texsize=round(gratingsize / 2);
visiblesize=2*texsize+1;
x = meshgrid(-texsize:texsize + p, 1);
white=1;
black=-1;
gray=0;
inc=white-gray;    
% Compute actual grating:
grating = gray + inc*sin(fr*x);

scFac = 10;
% gratingWidth = 2200;
imGrating = imresize(repmat(grating,length(grating),1),1/scFac);
% imGrating = imresize(imGrating(4800-gratingWidth:4801+gratingWidth,4800-gratingWidth:4801+gratingWidth),1/scFac);
centerPix = ceil(size(imGrating,1)/2);
%%
frameOffsets = -10:20;
staWidth = 110;
Y = zscore(stimExpt.dF_deconv(30:100,:),[],2);
sta = zeros((2*staWidth+1)^2,size(Y,1)*length(frameOffsets));
% Y = reshape(Y,[1 1 length(Y)]);
% sta = zeros((2*staWidth+1)^2,size(Y,1),8);
% sta = reshape(sta,[(2*staWidth+1)^2,size(Y,1),31]);
% Y = zscore(stimExpt.dF_deconv(1:200,:),[],2);
% Y = reshape(Y,[1 1 size(Y,1) size(Y,2)]);
% sta = zeros(2*staWidth+1,2*staWidth+1,size(Y,3),31);
if centerPix+4*staWidth+p/scFac > size(imGrating,2)
    error('imGrating is not large enough'),
end

numFrames = 0;
for nBlock = tmp.gratingBlocks
    tmp.f2p = interp1(stimExpt.psychTimes{nBlock},...
        1:length(stimExpt.psychTimes{nBlock}),stimExpt.frameTimes{nBlock},'nearest');
    tmp.f2p_valid = find(~isnan(tmp.f2p)); 
    blockDir = tmp.fDir{nBlock};
    blockSF = tmp.fSF{nBlock};
    blockPh = round(tmp.fPh{nBlock}/scFac);
    blockCT = tmp.fCT{nBlock};
    blockOffset = length(cat(1,stimExpt.frameTimes{1:nBlock-1}));
    
    parfor frame = tmp.f2p_valid(1)+30:tmp.f2p_valid(end)-30
        thisDir = blockDir(frame);
        thisSF = 2^blockSF(frame);
        thisPh = blockPh(frame);
        thisCT = blockCT(frame);
        thisWidth = ceil(staWidth*thisSF);
        thisInd = -thisWidth:thisWidth;
        thisGrating = imresize(thisCT*imGrating(centerPix+thisInd,centerPix+thisInd+thisPh),(2*staWidth+1)*[1 1],'bilinear');
        thisGrating = imrotate(thisGrating,thisDir,'bilinear','crop');
        traceFrame = frame + blockOffset;
        sta = sta + thisGrating(:).*reshape(Y(:,traceFrame+frameOffsets),1,[]);
%         sta = sta + thisGrating(:).*Y(:,traceFrame+4)';
%         thisRF = nan(size(sta,1),size(sta,2),1,size(sta,4));
%         parfor nNeuron = 1:size(Y,3)
%             thisRF = bsxfun(@times,thisGrating,Y(1,1,nNeuron,frame-10:frame+20));
%             sta(:,:,nNeuron,:) = sta(:,:,nNeuron,:) + thisRF;
%         end
%         sta = sta + bsxfun(@times,thisGrating,Y(1,1,:,frame-10:frame+20));
    end
    numFrames = numFrames + length(tmp.f2p_valid)-60;
end

staNorm = reshape(sta,[2*staWidth+1 2*staWidth+1 size(Y,1) length(frameOffsets)]) / numFrames;
% staNorm = reshape(sta,[2*staWidth+1 2*staWidth+1 size(Y,1)]) / numFrames;

% %%
% [X,Y] = meshgrid(1:1920);
% 
% ang = 180;
% projDir = [cosd(ang),sind(ang)];
% projVals = reshape([X(:),Y(:)]*projDir',1920,1920);
% figure,imagesc(sin(projVals*fr))
function StimCentroids = genStimCentroids(imFile,showFig)

if ~exist('showFig','var') || isempty(showFig)
    showFig = 0;
end

[imDual,imMeta] = tiffRead(imFile,'double');

%% Identify candidate centroids

% Estimate cell size in pixels from zoom level (calibrated w/ stim path on 
% Dec 2 2014 to correspond to ~12um)
zoomLvl = imMeta.acq.zoomFactor;
cellDiam = 7.5 * zoomLvl;

% Filter red image
im = imDual(:,:,2);
imFilt = medfilt2(im,[1 1]*round(cellDiam/3),'symmetric');
blurFilter = fspecial('gaussian',250,cellDiam*2);
blurImage = imfilter(imFilt,blurFilter,'replicate');
divRef = imFilt ./ blurImage;
subRef = imFilt - blurImage;

% Greyscale morphological processing w/ cell-sized ball SE
cellSE = strel('ball',round(cellDiam/1.5),1,0);
openRef = imopen(divRef,cellSE);
refPks = imregionalmax(openRef);
maxVals = subRef(refPks);
[maxI,maxJ] = find(refPks);
[~,pkOrd] = sort(maxVals,1,'descend');
StimCentroids = [maxI(pkOrd),maxJ(pkOrd)];

% Show reference and top ROI candidates if desired
if showFig
    figure,imshow(imadjust(imFilt/max(imFilt(:)))),hold on
    col = flipud(parula(300));
    for i=1:300
        plot(StimCentroids(i,2),StimCentroids(i,1),'*','color',col(i,:))
    end
end
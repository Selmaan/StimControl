%Rough outline of an algorithm to identify cells from static reference
%images for purposes of creating stimulation ROIs

%%
close all,
cellDiam = 15;
%im = r2;

%%
imFilt = medfilt2(im,[1 1]*round(cellDiam/3),'symmetric');
blurFilter = fspecial('gaussian',300,cellDiam*2);
blurImage = imfilter(imFilt,blurFilter,'replicate');
ref = imFilt ./ blurImage;
refSub = imFilt - blurImage;

%%
cellSE = strel('ball',round(cellDiam/2),1.5,0);
openRef = imopen(ref,cellSE);
refPks = imregionalmax(openRef);
maxInds = find(refPks);
[maxI,maxJ] = find(refPks);
maxVals = refSub(maxInds);
[~,pkOrd] = sort(maxVals,1,'descend');

%%

col = flipud(parula(300));
figure,imshow(imFilt,[]),hold on,
for i=1:300
    plot(maxJ(pkOrd(i)),maxI(pkOrd(i)),'*','color',col(i,:))
end


% 
% hROIfig = figure;imagesc(ref),hold on,
% plot(maxJ(pkOrd(1:100)),maxI(pkOrd(1:100)),'k*')
% plot(maxJ(pkOrd(101:200)),maxI(pkOrd(101:200)),'r*')

% hMaster = figure;imagesc(im)
% hROIfig = figure;imagesc(ref),hold on,
% currentROI = 0;
% while true
%     figure(hROIfig),
%     currentROI = currentROI+1;
%     roiInd = pkOrd(currentROI);
%     ylim(maxI(roiInd) + [-cellDiam*2 cellDiam*2]),
%     xlim(maxJ(roiInd) + [-cellDiam*2 cellDiam*2]),
%     plot(maxJ(roiInd),maxI(roiInd),'k*'),
%     pause,
% end
    
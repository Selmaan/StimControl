%% Repetition / Decrement Effect
figure,imagesc(corrcoef(repStim(stimCells,:))-eye(size(repStim,2)))
figure,plot(repStim(stimCells,:)'),hold on,
plot(mean(repStim(stimCells,:)),'k','linewidth',2)
plot(median(repStim(stimCells,:)),'r','linewidth',2)

%% Response Mat
figure,imagesc(respMat(stimCells,stimCells)),
title('stimCells Response Mat'),
xlabel('Responding Neuron'),ylabel('Targeted Neuron'),

%% Response by Distance scatter + ecdf
respMatG = respMat(:,respCells);
distMatG = distMat(1:size(respMat,1),respCells);
[sortDist,sortDistInd] = sort(distMatG,1,'ascend');
sortResp = [];
for i=1:size(respMatG,2)
    sortResp(:,i) = respMatG(sortDistInd(:,i),i);
end
figure,plot(sortDist,sortResp,':')
hold on
plot(sortDist,sortResp,'.','markersize',10)
d0 = distMatG(:)==0;
d1 = distMatG(:)>0 & distMatG(:)<20;
d2 = distMatG(:)>20 & distMatG(:)<40;
d3 = distMatG(:)>40 & distMatG(:)<60;
d4 = distMatG(:)>60 & distMatG(:)<80;
dLarge = distMatG(:)>80;
plot([mean(distMatG(d0)), mean(distMatG(d1)), mean(distMatG(d2)), ...
    mean(distMatG(d3)), mean(distMatG(d4)), mean(distMatG(dLarge))],...
    [mean(respMatG(d0)), mean(respMatG(d1)), mean(respMatG(d2)), ...
    mean(respMatG(d3)), mean(respMatG(d4)), mean(respMatG(dLarge))],...
    'k','linewidth',2);
xlabel('Distance (um)'),
ylabel('Response (spikes)')
figure, hold on,
ecdf(respMatG(d0))
ecdf(respMatG(d1))
ecdf(respMatG(d2))
ecdf(respMatG(d3))
ecdf(respMatG(d4))
ecdf(respMatG(dLarge))

%% Expression level analysis
if exist('rLin','var')
    roiMask = zeros(512);
    roiSizes = [0.0075 0.0075];
    figure,imshow(imNorm(rLin),linRA),
    for i=1:size(roiCentroid,1)
        roiLoc = roiCentroid(i,:);
        roiSize = roiSizes;
        h = imellipse(gca,[roiLoc-roiSize 2*roiSize]);
        m = createMask(h);
        expLvl(i) = mean(rLin(m));
        delete(h),
    end
    clear m

    figure,plot(expLvl(stimCells),stimMag(stimCells),'.','markersize',10)
    xlabel('C1V1 Expression'),
    ylabel('Response Spikes'),
else
    warning('Cannot Analyze Expression: Linear Galvo Image not Loaded');
end
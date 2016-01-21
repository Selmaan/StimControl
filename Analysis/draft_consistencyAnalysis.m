nRepeats = size(pkStim,3);
b1_end = floor(nRepeats/2);
nPartitions = 1e3;
spkThresh = 1;
stimCells = find(stimMag>spkThresh);
respCells = find([roi.group]==1 | [roi.group]==9);
distThresh = 20;

trueCons = nan(nPartitions,length(respCells));
shufCons = nan(nPartitions,length(respCells));
for nPartition = 1:nPartitions
    nPartition,
    thisPart = randperm(nRepeats);
    pA = mean(pkStim(:,:,thisPart(1:b1_end)),3);
    pB = mean(pkStim(:,:,thisPart(b1_end+1:end)),3);
    for nROI = 1:length(respCells)
        iROI = respCells(nROI);
        cellDist = distMat(:,iROI);
        validCells = intersect(find(cellDist > distThresh),stimCells);
        validA = pA(validCells,iROI);
        shufA = validA(randperm(length(validA)));
        validB = pB(validCells,iROI);
        shufB = validB(randperm(length(validB)));
        trueCons(nPartition,nROI) = corr(validA,validB);
        shufCons(nPartition,nROI) = corr(shufA,shufB);
    end
end

%% Plots
figure,hold on
ksdensity(shufCons(:))
ksdensity(trueCons(:))
legend('Shuffled Correlations','True Correlations')

adjCons = trueCons-shufCons;
ctrlCons = shufCons - shufCons(randperm(1e3),:);
figure,hold on
ksdensity(ctrlCons(:))
ksdensity(adjCons(:))
legend('Control Difference','True Difference')

figure,histogram(sum(adjCons<0),10)
neurReliable = sum(adjCons<0)<=nPartitions/100;

rMat = mean(pkStim,3);
rMat = rMat-diag(diag(rMat));
rMat = rMat(stimCells,respCells);
dMat = distMat(stimCells,respCells);

cMap = lines(2);
figure,plot(dMat(:,~neurReliable),rMat(:,~neurReliable),'.','color',cMap(1,:),'markersize',10)
hold on,plot(dMat(:,neurReliable),rMat(:,neurReliable),'.','color',cMap(2,:),'markersize',10)

% rMat = 
% figure,imagesc([respMat(:,neurReliable),respMat(:,~neurReliable)],[0 prctile(respMat(:),99.9)])
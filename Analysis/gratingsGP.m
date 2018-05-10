%%
allResp = randomGratingsRespStruct(stimExpt);
% [oH, oPh, gPar] = fitRandomGratingsGP(allResp);
% tR = rgTuningCurvesGP(allResp, oH, oPh, gPar);
% save('cvGPfits','oH','oPh','gPar','tR'),

%% Selection criteria
idTargets = find(stimExpt.targetLabel>=1);
stimMagThresh = 0.1;
predCorrThresh = 0.3;
overFitThresh = 0.2;
distThresh = 25;

[nRespMat, pRespMat, visResid, deResp, stimID, visOri, visCon, stimMag, mvSpd] =...
    calcStimShuffle(stimExpt, distThresh);
[stimBeta,stimBetaVar,respBeta,respBetaVar,contBeta,contBetaVar,deResp,preResp,stimID,visOri,visCon,mvSpd] = ... 
    influenceRegression(stimExpt, distThresh);

overFit = tR.trainCorr(:)-gPar.predCorr(:);
validFits = find(overFit(:)<overFitThresh & gPar.predCorr(:)>predCorrThresh);
validStim = idTargets(intersect(find(mean(stimMag,2) > stimMagThresh),validFits));
validStim_fitInd = intersect(find(mean(stimMag,2) > stimMagThresh),validFits);

validInfluence = stimBeta(validFits,validStim)./sqrt(stimBetaVar(validFits,validStim));
tuneRange = squeeze(range(tR.neurTuning(:,validFits,1:4)./sqrt(tR.neurTuning(:,validFits,5:8))));
distMat = stimExpt.cellStimDistMat(validFits,validStim)*stimExpt.xConvFactor;



%%
infPairDists = distMat>100 & distMat<500;
% infPairDists = distMat<100;

% tuneVals = 1:4;
% allTuneCurves = tR.neurTuning(:,[validStim_fitInd;validFits],tuneVals);
% allTuneCurves = bsxfun(@minus,allTuneCurves,mean(allTuneCurves));
% catTuneCurves = reshape(permute(allTuneCurves,[1 3 2]),360*size(allTuneCurves,3),size(allTuneCurves,2));

allTuneCurves = tR.ctTrain(:,[validStim_fitInd;validFits]);
catTuneCurves = allTuneCurves;

% allTuneCurves = allResp.Y(:,[validStim_fitInd;validFits]);
% catTuneCurves = allTuneCurves;

% allTuneCurves = traceGratings(:,[validStim_fitInd;validFits]);
% catTuneCurves = allTuneCurves;


corrTuneCurves = corr(catTuneCurves(:,length(validStim)+1:end),catTuneCurves(:,1:length(validStim)));

corrTuneCurves = corrTuneCurves(infPairDists);
theseInf = validInfluence(infPairDists);
% nanmean(theseInf(corrTuneCurves>median(corrTuneCurves)))
% nanmean(theseInf(corrTuneCurves<median(corrTuneCurves)))
% nanmean(validInfluence(corrTuneCurves<prctile(corrTuneCurves,25))),
% nanmean(validInfluence(corrTuneCurves>prctile(corrTuneCurves,25) & corrTuneCurves<prctile(corrTuneCurves,50)))
% nanmean(validInfluence(corrTuneCurves>prctile(corrTuneCurves,50) & corrTuneCurves<prctile(corrTuneCurves,75)))
% nanmean(validInfluence(corrTuneCurves>prctile(corrTuneCurves,75))),
prcBin = [];
for i=0:90
    prcBin(i+1) = nanmean(theseInf(corrTuneCurves>prctile(corrTuneCurves,i) & corrTuneCurves<prctile(corrTuneCurves,i+10)));
end
figure,plot(5:95,prcBin,'linewidth',2)
xlabel('Tuning Correlation Percentile'),
ylabel('Mean Influence'),
%%
nNeuron = 157,
X = [cosd(allResp.Dir),sind(allResp.Dir),...
    allResp.SF,allResp.TF,sqrt(allResp.spd)];
% gratingBlock = zeros(length(allResp.Dir),1);
% gratingBlock(1:allResp.nCycles(1)) = 1;
% gratingBlock(allResp.nCycles(1)+1:sum(allResp.nCycles)) = 2;
% X = [cosd(allResp.Dir),sind(allResp.Dir),...
%     allResp.SF,allResp.TF,sqrt(allResp.spd), gratingBlock];
% Y = allResp.Y(:,nNeuron);
% Y = allResp.Y(:,nNeuron)/std(allResp.Y(:,nNeuron));
Y = sqrt(allResp.Y(:,nNeuron))/std(sqrt(allResp.Y(:,nNeuron)));

hyp = struct;
% meanFunc = {@meanConst}; hyp.mean = 0;
meanFunc = [];
% covFun1 = {@covMask, {[1 1 0 0 0], {@covSE,'iso',[]}}};
% covFun2 = {@covMask, {[0 0 1 1 1], {@covSE,'ard',[]}}};
% covFunc = {@covScale {@covProd, {covFun1, covFun2}}};
% covFun2 = {@covMask, {[0 0 1 0 0], {@covSE,'iso',[]}}}';
% covFun3 = {@covMask, {[0 0 0 1 0], {@covSE,'iso',[]}}}';
% covFun4 = {@covMask, {[0 0 0 0 1], {@covSE,'iso',[]}}}';
% covFunc = {@covScale {@covSum, {covFun1, covFun2, covFun3, covFun4}}};
covFun1 = {@covMask, {[1 1 0 0 0], {@covSE,'iso',[]}}};
covFun2 = {@covMask, {[0 0 1 0 0], {@covSE,'iso',[]}}}';
covFun3 = {@covMask, {[0 0 0 1 0], {@covSE,'iso',[]}}}';
covFun4 = {@covMask, {[0 0 0 0 1], {@covSE,'iso',[]}}}';
covFunc = {@covScale, {@covProd, {covFun1, covFun2, covFun3, covFun4}}};

hyp.cov = zeros(eval(feval(covFunc{:})),1);

likFunc = {@likGauss};
% likFunc = {@likNegBinom, 'exp'};
% likFunc = {@likT};
% likFunc = {@likPoisson,'exp'};
% likFunc = {@likMix {{@likNegBinom, 'exp'} {@likGauss}}};
hyp.lik = zeros(eval(feval(likFunc{:})),1);

% optHyp = minimize(hyp, @gp, -75, ...
%         @infGaussLik, meanFunc, covFunc, likFunc, X, Y);
% yMu = gp(optHyp, @infGaussLik, meanFunc, covFunc, likFunc, X, Y, X);
optHyp = minimize(hyp, @gp, -60, ...
        @infLaplace, meanFunc, covFunc, likFunc, X, Y);
yMu = gp(optHyp, @infLaplace, meanFunc, covFunc, likFunc, X, Y, X);

exp(optHyp.cov(1:end-1))./range(X(:,2:end))',
% optHyp.cov(1:end-1)
figure,scatter(allResp.Dir,allResp.SF,[],yMu,'filled'),
title('Predictions'),xlabel('Dir'),ylabel('SF'),colorbar,
figure,scatter(allResp.Dir,allResp.SF,[],Y,'filled'),
title('Real Data'),xlabel('Dir'),ylabel('SF'),colorbar,
% figure,scatter(allResp.Dir,allResp.SF,30/mean(Y)*(yMu+eps(1)-min(yMu)),allResp.spd,'filled'),title('Predictions'),xlabel('Dir'),ylabel('SF'),
% figure,scatter(allResp.Dir,allResp.SF,30/mean(Y)*(Y+eps(1)-min(yMu)),allResp.spd,'filled'),title('Real Data'),xlabel('Dir'),ylabel('SF'),
figure,plot(Y,yMu,'.'),xlabel('Real Values'),ylabel('Predicted Values'),

%%
nCV = 10;
predVals = [];
for i=1:nCV
    i,
    trainInd = randperm(length(Y),round(.9*length(Y)));
    testInd = setdiff(1:length(Y),trainInd);
    optHyp = minimize(hyp, @gp, -75, @infGaussLik, meanFunc, covFunc, likFunc, X(trainInd,:), Y(trainInd));
    [yMu,yVar] = gp(optHyp, @infGaussLik, meanFunc, covFunc, likFunc, X(trainInd,:), Y(trainInd), X(testInd,:));
    predVals = cat(1,predVals,[Y(testInd),yMu]);
end

figure,plot(predVals(:,1),predVals(:,2),'.'),
title(sprintf('Prediction Correlation %0.3f',corr(predVals(:,1),predVals(:,2)))),
xlabel('True Values'),ylabel('Predicted Values'),

%%
samplingDensity = 8;
tmp = struct;
tmp.rangeFact = max(ceil(samplingDensity*range(X(:,2:end))'./exp(optHyp.cov(1:end-1))),3);
tmp.rangeFact(1) = max(2*tmp.rangeFact(1),24);
tmp.valDir = 360/tmp.rangeFact(1):360/tmp.rangeFact(1):360;
tmp.valSF = linspace(-2,2,tmp.rangeFact(2));
tmp.valTF = linspace(-2,3,tmp.rangeFact(3));
tmp.valSpd = linspace(min(X(:,end)),max(X(:,end)),tmp.rangeFact(4));
[tmp.g1,tmp.g2,tmp.g3,tmp.g4] = ndgrid(tmp.valDir,tmp.valSF,tmp.valTF,tmp.valSpd);
tmp.gCos = cosd(tmp.g1);
tmp.gSin = sind(tmp.g1);
tmp.gAll = cat(2,tmp.gCos(:),tmp.gSin(:),tmp.g2(:),tmp.g3(:),tmp.g4(:));
tic,[tmp.yMu,tmp.yVar] = gp(optHyp, @infLaplace, meanFunc, covFunc, likFunc, X, Y, tmp.gAll);toc,
figure,imagesc(flipud(squeeze(mean(mean(reshape(tmp.yMu,size(tmp.g1)),4),3))'))
T = tensor(reshape(tmp.yMu,size(tmp.g1)));
P = cp_als(T,1,'tol',1e-6);
figure,plot(tmp.valDir,P.U{1}),title('Direction Tuning'),
figure,plot(tmp.valSF,P.U{2}),title('SF Tuning'),
figure,plot(tmp.valTF,P.U{3}),title('TF Tuning'),
figure,plot(tmp.valSpd,P.U{4}),title('Speed Tuning'),
% figure,imagesc(flipud(squeeze(mean(mean(y./yVar,4),3))'))
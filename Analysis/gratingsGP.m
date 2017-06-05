%%

allResp = randomGratingsRespStruct(stimExpt);



%%


exp(optHyp.cov(1:4))./range(X(:,2:end))',
figure,scatter(allResp.Dir,allResp.SF,[],yMu,'filled'),
title('Predictions'),xlabel('Dir'),ylabel('SF'),colorbar,
figure,scatter(allResp.Dir,allResp.SF,[],Y,'filled'),
title('Real Data'),xlabel('Dir'),ylabel('SF'),colorbar,
% figure,scatter(allResp.Dir,allResp.SF,30/mean(Y)*(yMu+eps(1)-min(yMu)),allResp.spd,'filled'),title('Predictions'),xlabel('Dir'),ylabel('SF'),
% figure,scatter(allResp.Dir,allResp.SF,30/mean(Y)*(Y+eps(1)-min(yMu)),allResp.spd,'filled'),title('Real Data'),xlabel('Dir'),ylabel('SF'),
figure,plot(Y,yMu,'.'),xlabel('Real Values'),ylabel('Predicted Values'),

%%
nCV = 5;
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
samplingDensity = 6;
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
tic,[tmp.yMu,tmp.yVar] = gp(optHyp, @infGaussLik, meanFunc, covFunc, likFunc, X, Y, tmp.gAll);toc,
figure,imagesc(flipud(squeeze(mean(mean(reshape(tmp.yMu,size(tmp.g1)),4),3))'))
T = tensor(reshape(tmp.yMu,size(tmp.g1)));
P = cp_als(T,1,'tol',1e-6);
figure,plot(tmp.valDir,P.U{1}),title('Direction Tuning'),
figure,plot(tmp.valSF,P.U{2}),title('SF Tuning'),
figure,plot(tmp.valTF,P.U{3}),title('TF Tuning'),
figure,plot(tmp.valSpd,P.U{4}),title('Speed Tuning'),
% figure,imagesc(flipud(squeeze(mean(mean(y./yVar,4),3))'))
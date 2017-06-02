%%
tmp = struct;
allResp = struct;

tmp.gratingBlocks = find(~stimExpt.stimBlocks);
for nBlock = tmp.gratingBlocks
    tmp.Dir = stimExpt.stimInfo{nBlock}(6:6:end);
    tmp.SF = stimExpt.stimInfo{nBlock}(7:6:end);
    tmp.TF = stimExpt.stimInfo{nBlock}(8:6:end)./tmp.SF;
    tmp.TF = stimExpt.stimInfo{nBlock}(8:6:end);
    tmp.CT = stimExpt.stimInfo{nBlock}(9:6:end);
    tmp.Ph = stimExpt.stimInfo{nBlock}(10:6:end);
    
    tmp.fSpd = sqrt(sum(stimExpt.ballVel{nBlock}.^2,2));
    
    tmp.f2p = interp1(stimExpt.psychTimes{nBlock},...
        1:length(stimExpt.psychTimes{nBlock}),stimExpt.frameTimes{nBlock},'nearest');
    tmp.f2p_valid = find(~isnan(tmp.f2p));
    tmp.fCT = nan(length(stimExpt.frameTimes{nBlock}),1);
    tmp.fDir(tmp.f2p_valid) = tmp.Dir(tmp.f2p(tmp.f2p_valid));
    tmp.fSF(tmp.f2p_valid) = log2(tmp.SF(tmp.f2p(tmp.f2p_valid)));
    tmp.fTF(tmp.f2p_valid) = log2(tmp.TF(tmp.f2p(tmp.f2p_valid)));
    tmp.fCT(tmp.f2p_valid) = tmp.CT(tmp.f2p(tmp.f2p_valid));
    tmp.fPh(tmp.f2p_valid) = tmp.Ph(tmp.f2p(tmp.f2p_valid));
    tmp.smCT = conv(tmp.fCT,gausswin(15)/sum(gausswin(15)),'same');
    tmp.ctTrig = 1+find(diff(tmp.smCT(2:end))>0 & diff(tmp.smCT(1:end-1)) < 0);
    tmp.blockOffsetFrame = length(cat(1,stimExpt.frameTimes{1:nBlock-1}));
    tmp.traces = stimExpt.dF_deconv(:,tmp.blockOffsetFrame+1:tmp.blockOffsetFrame+length(stimExpt.frameTimes{nBlock}));
    tmp.cycleDur = mode(diff(tmp.ctTrig));
    fprintf('Block %d had %d cycles at %d frames-per-cycle \n',nBlock,length(tmp.ctTrig)-1,tmp.cycleDur);
    for nCycle = 1:length(tmp.ctTrig)-1
        tmp.cycleInd = tmp.ctTrig(nCycle) + (1:tmp.cycleDur);
        allResp.Y{nBlock}(:,nCycle) = mean(tmp.traces(:,tmp.cycleInd),2);
        allResp.Dir{nBlock}(nCycle) = mode(tmp.fDir(tmp.cycleInd));
        allResp.SF{nBlock}(nCycle) = mode(tmp.fSF(tmp.cycleInd));
        allResp.TF{nBlock}(nCycle) = mode(tmp.fTF(tmp.cycleInd));
        allResp.spd{nBlock}(nCycle) = mean(tmp.fSpd(tmp.cycleInd));
    end
end

allResp.Y = cat(2,allResp.Y{:})';
allResp.Dir = cat(2,allResp.Dir{:})';
allResp.SF = cat(2,allResp.SF{:})';
allResp.TF = cat(2,allResp.TF{:})';
allResp.spd = cat(2,allResp.spd{:})';

clear tmp
%%
close all,
nTrace = randi(size(allResp.Y,2));
X = [cosd(allResp.Dir),sind(allResp.Dir),allResp.SF,allResp.TF,sqrt(allResp.spd)];
Y = sqrt(allResp.Y(:,nTrace)); Y = Y - mean(Y);

hyp = struct;
meanFunc = [];
% covFunc = @covSEard; hyp.cov = [3;0;0;0;0];
covFun1 = {@covMask, {[1 1 0 0 0], {@covSE,'iso',[]}}};
covFun2 = {@covMask, {[0 0 1 1 1], {@covSE,'ard',[]}}};
covFunc = {@covScale {@covProd, {covFun1, covFun2}}}; 
hyp.cov = zeros(eval(feval(covFunc{:})),1); hyp.cov(end) = -1;
likFunc = @likGauss; hyp.lik = -1;

optHyp = minimize(hyp, @gp, -75, @infGaussLik, meanFunc, covFunc, likFunc, X, Y);
[yMu,yVar,lMu,lVar] = gp(optHyp, @infGaussLik, meanFunc, covFunc, likFunc, X, Y, X);
exp(optHyp.cov(1:end-1))./range(X(:,2:end))',
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
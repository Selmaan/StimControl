function tuneResults = rgTuningCurvesGP(allResp, oH, oPh, gPar)

tuneResults = struct;

%% Training Data Predictions
yTrain = nan(size(gPar.Y));
trainCorr = nan(size(gPar.Y,2),1);
ctTrain = nan(size(gPar.yPh));
ctTrainCorr = nan(size(gPar.yPh,2),1);
for nNeur = 1:length(oH)
    if ~isempty(oH(nNeur).mean)
        yTrain(:,nNeur) = gp(oH(nNeur), gPar.infFunc, ...
            gPar.meanFunc, gPar.covFunc, gPar.likFunc, gPar.X, gPar.Y(:,nNeur), gPar.X);
        trainCorr(nNeur) = corr(yTrain(:,nNeur),gPar.Y(:,nNeur));

        ctTrain(:,nNeur) = gp(oPh(nNeur), @infGaussLik, [], ...
            gPar.covFuncPh, gPar.likFuncPh, gPar.xPh, gPar.yPh(:,nNeur), gPar.xPh);
        ctTrainCorr(nNeur) = corr(ctTrain(:,nNeur),gPar.yPh(:,nNeur));
    end
end

tuneResults.yTrain = yTrain;
tuneResults.trainCorr = trainCorr;
tuneResults.ctTrain = ctTrain;
tuneResults.ctTrainCorr = ctTrainCorr;

%% Expand around max response and extract 1-d tunings

% These values were chosen to correspond to a 'naive' distance of 1, such
% that later scaling them by the learned lengthscale gives us a range of 1
% fitted lengthscale explored for all neurons & dimensions
expDir = -30:5:30;
expSF = -.5:.1:.5;
expTF = -.5:.1:.5;
expSpd = -.5:.1:.5;

tunDir = linspace(1,360,360);
tunSF = linspace(floor(min(allResp.SF)),ceil(max(allResp.SF)),360);
tunTF = linspace(floor(min(allResp.TF)),ceil(max(allResp.TF)),360);
tunSpd = linspace(0,max(sqrt(allResp.spd)),360);

[~, maxPred] = max(yTrain);
neurDir = nan(length(tunDir),length(oH));
neurSF = nan(length(tunSF),length(oH));
neurTF = nan(length(tunTF),length(oH));
neurSpd = nan(length(tunSpd),length(oH));
varDir = nan(length(tunDir),length(oH));
varSF = nan(length(tunSF),length(oH));
varTF = nan(length(tunTF),length(oH));
varSpd = nan(length(tunSpd),length(oH));
% parfor nNeur = 1:length(oH)
for nNeur = 1:length(oH)
    if ~isempty(oH(nNeur).mean)
    nNeur,
    indMax = maxPred(nNeur);
    maxDir = allResp.Dir(indMax);
    maxSF = allResp.SF(indMax);
    maxTF = allResp.TF(indMax);
    maxSpd = sqrt(allResp.spd(indMax));
   
    tDir = maxDir + expDir*exp(oH(nNeur).cov(1));
    tSF = maxSF + expSF*exp(oH(nNeur).cov(2));
    tTF = maxTF + expTF*exp(oH(nNeur).cov(3));
    tSpd = maxSpd + expSpd*exp(oH(nNeur).cov(4));
    
    tDir = mod(tDir, 360);
    tSF = max(min(tSF, max(tunSF)),min(tunSF));
    tTF = max(min(tTF, max(tunTF)),min(tunTF));
    tSpd = max(min(tSpd, max(tunSpd)),min(tunSpd));

    [expPred, ~, pDir, pSF, pTF, pSpd] = ...
        gridPredGP(tDir, tSF, tTF, tSpd, oH(nNeur), gPar, gPar.Y(:,nNeur));
    [~, maxExpPred] = max(expPred);
    optDir = pDir(maxExpPred);
    optSF = pSF(maxExpPred);
    optTF = pTF(maxExpPred);
    optSpd = pSpd(maxExpPred);
    
    if abs(optDir-maxDir) == max(abs(expDir))
        warning('Direction Expansion Reached Limit'),
        keyboard,
    elseif abs(optSF-maxSF) == max(abs(expSF))
        warning('SF Expansion Reached Limit'),
        keyboard,
    elseif abs(optTF-maxTF) == max(abs(expTF))
        warning('TF Expansion Reached Limit'),
        keyboard,
    elseif abs(optSpd-maxSpd) == max(abs(expSpd))
        warning('Speed Expansion Reached Limit'),
        keyboard,
    end
    
    [neurDir(:,nNeur), varDir(:,nNeur)] = gridPredGP(tunDir, optSF, optTF, optSpd, ...
        oH(nNeur), gPar, gPar.Y(:,nNeur));
    [neurSF(:,nNeur),varSF(:,nNeur)] = gridPredGP(optDir, tunSF, optTF, optSpd, ...
        oH(nNeur), gPar, gPar.Y(:,nNeur));
    [neurTF(:,nNeur), varTF(:,nNeur)] = gridPredGP(optDir, optSF, tunTF, optSpd, ...
        oH(nNeur), gPar, gPar.Y(:,nNeur));
    [neurSpd(:,nNeur), varSpd(:,nNeur)] = gridPredGP(optDir, optSF, optTF, tunSpd, ...
        oH(nNeur), gPar, gPar.Y(:,nNeur));
    end
end

tuneResults.tunDir = tunDir;
tuneResults.tunSF = tunSF;
tuneResults.tunTF = tunTF;
tuneResults.tunSpd = tunSpd;
tuneResults.neurTuning = cat(3, neurDir, neurSF, neurTF, neurSpd, ...
    varDir, varSF, varTF, varSpd);

end


function [gridPred, gridVar, pDir, pSF, pTF, pSpd] = gridPredGP(tDir, tSF, tTF, tSpd, oH, gPar, Y)

[pDir, pSF, pTF, pSpd] = ndgrid(tDir, tSF, tTF, tSpd);
pCos = cosd(pDir);
pSin = sind(pDir);
pAll = cat(2,pCos(:), pSin(:), pSF(:), pTF(:), pSpd(:));
% [~, ~, gridPred, gridVar] = gp(oH, gPar.infFunc, ...
%     gPar.meanFunc, gPar.covFunc, gPar.likFunc, gPar.X, Y, pAll);
[gridPred, gridVar] = gp(oH, gPar.infFunc, ...
    gPar.meanFunc, gPar.covFunc, gPar.likFunc, gPar.X, Y, pAll);
end


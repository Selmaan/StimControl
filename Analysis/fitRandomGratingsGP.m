function [optHyp, optHypPh, params] = fitRandomGratingsGP(allResp,nNeurons,kFolds)

if nargin < 2 || isempty(nNeurons)
    nNeurons = 1:size(allResp.Y,2);
end

if nargin < 3 || isempty(kFolds)
    kFolds = 10;
end

%% Optimize cycle parameters

% if length(allResp.nCycles)>2
%     error('Function does not support more than two gratings blocks'),
% end

X = [cosd(allResp.Dir),sind(allResp.Dir),...
    allResp.SF,allResp.TF,sqrt(allResp.spd)];
% gratingBlock = zeros(length(allResp.Dir),1);
% gratingBlock(1:allResp.nCycles(1)) = 1;
% gratingBlock(allResp.nCycles(1)+1:sum(allResp.nCycles)) = 2;
% 
% X = [cosd(allResp.Dir),sind(allResp.Dir),...
%     allResp.SF,allResp.TF,sqrt(allResp.spd), gratingBlock];

Y = sqrt(allResp.Y(:,nNeurons)); Y = bsxfun(@rdivide,Y,std(Y));
likFunc = @likGauss;
infFunc = @infGaussLik;
% Y = bsxfun(@rdivide,allResp.Y(:,nNeurons),std(allResp.Y(:,nNeurons)));
% likFunc = {@likNegBinom, 'logistic'}; 
% infFunc = @infLaplace;
% warning('Using Negative Binomial liklihood'),

hyp = struct;
hyp.lik = 0;
meanFunc = {@meanConst}; hyp.mean = 0;
covFun1 = {@covMask, {[1 1 0 0 0], {@covSE,'iso',[]}}};
covFun2 = {@covMask, {[0 0 1 1 1], {@covSE,'ard',[]}}};
covFunc = {@covScale {@covProd, {covFun1, covFun2}}};
% covFun2 = {@covMask, {[0 0 1 1 0], {@covSE,'ard',[]}}};
% covFun3 = {@covMask, {[0 0 0 0 1], {@covNNone}}};
% covFunc = {@covProd, {covFun1, covFun2, covFun3,}}; 
% covFunc = {@covScale {@covProd, {covFun1, covFun2, covFun3,}}}; 
% covFunc = {@covProd, {{@covScale {@covProd, {covFun1, covFun2}}}, covFun3}}; 
hyp.cov = zeros(eval(feval(covFunc{:})),1); %hyp.cov(end) = -1;


params.meanFunc = meanFunc;
params.covFunc = covFunc;
params.likFunc = likFunc;
params.infFunc = infFunc;
params.initHyp = hyp;
params.X = X;
params.Y = Y;
params.nNeurons = nNeurons;

%% 
if kFolds > 1
    cvFolds = cvpartition(size(Y,1),'KFold',kFolds);
    allPreds = nan(size(Y));
    for k = 1:kFolds
        fprintf('\n \n Fitting fold %d of %d\n',k,kFolds),
        xTrain = X(cvFolds.training(k),:);
        yTrain = Y(cvFolds.training(k),:);
        xTest = X(cvFolds.test(k),:);
        yTest = Y(cvFolds.test(k),:);
        foldPreds = nan(size(yTest));
        parfor nNeuron = 1:size(Y,2)
            if sum(Y(:,nNeuron)) > 1
                cvHyp = minimize(hyp, @gp, -75, ...
                    infFunc, meanFunc, covFunc, likFunc, xTrain, yTrain(:,nNeuron)); 
                foldPreds(:,nNeuron) = gp(cvHyp, infFunc, meanFunc, ...
                    covFunc, likFunc, xTrain, yTrain(:,nNeuron), xTest);
            end
        end
        allPreds(cvFolds.test(k),:) = foldPreds;          
    end

    params.cvPreds = allPreds;
    for nNeuron = 1:size(Y,2)
        params.predCorr(nNeuron) = corr(Y(:,nNeuron),allPreds(:,nNeuron));
    end
end

fprintf('\n \n Fitting model to Full dataset \n'),
parfor nNeuron = 1:size(Y,2)
    if sum(Y(:,nNeuron)) > 1
        optHyp{nNeuron} = minimize(hyp, @gp, -100, ...
            infFunc, meanFunc, covFunc, likFunc, X, Y(:,nNeuron)); 
    end
end
optHyp = cat(1,optHyp{:});
if length(optHyp) ~= size(Y,2)
    warning('Some Cells were ignored due to no response data'),
    validFits = find(sum(Y)>1);
    invalidFits = find(sum(Y)<1);
    tmpHyp(validFits) = optHyp;
    optHyp = tmpHyp;
end
%% Optimize contrast-phase parameters

xPh = [cosd(3:3:360)',sind(3:3:360)'];
yPh = zscore(allResp.yPh(:,nNeurons));

hypPh = struct;
covFuncPh = @covSEiso; hypPh.cov = [0; 0];
likFuncPh = @likGauss; hypPh.lik = 0;

params.covFuncPh = covFuncPh;
params.likFuncPh = likFuncPh;
params.initHypPh = hypPh;
params.xPh = xPh;
params.yPh = yPh;

parfor nNeuron = 1:size(Y,2)
    optHypPh(nNeuron) = minimize(hypPh, @gp, -100, ...
        @infGaussLik, [], covFuncPh, likFuncPh, xPh, yPh(:,nNeuron));    
end
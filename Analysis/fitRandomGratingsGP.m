function [optHyp, optHypPh params] = fitRandomGratingsGP(allResp,nNeurons)

if nargin < 2
    nNeurons = 1:size(allResp.Y,2);
end

%% Optimize cycle parameters

X = [cosd(allResp.Dir),sind(allResp.Dir),...
    allResp.SF,allResp.TF,sqrt(allResp.spd)];
Y = zscore(sqrt(allResp.Y(:,nNeurons)));

hyp = struct;
meanFunc = [];
covFun1 = {@covMask, {[1 1 0 0 0], {@covSE,'iso',[]}}};
covFun2 = {@covMask, {[0 0 1 1 1], {@covSE,'ard',[]}}};
covFunc = {@covScale {@covProd, {covFun1, covFun2}}};
% covFun2 = {@covMask, {[0 0 1 1 0], {@covSE,'ard',[]}}};
% covFun3 = {@covMask, {[0 0 0 0 1], {@covNNone}}};
% covFunc = {@covProd, {covFun1, covFun2, covFun3,}}; 
% covFunc = {@covScale {@covProd, {covFun1, covFun2, covFun3,}}}; 
% covFunc = {@covProd, {{@covScale {@covProd, {covFun1, covFun2}}}, covFun3}}; 
hyp.cov = zeros(eval(feval(covFunc{:})),1); %hyp.cov(end) = -1;
likFunc = @likGauss; hyp.lik = 0; %hyp.lik = -1;

params.meanFunc = meanFunc;
params.covFunc = covFunc;
params.likFunc = likFunc;
params.initHyp = hyp;
params.X = X;
params.Y = Y;
params.nNeurons = nNeurons;

parfor nNeuron = 1:size(Y,2)
    optHyp(nNeuron) = minimize(hyp, @gp, -100, ...
        @infGaussLik, meanFunc, covFunc, likFunc, X, Y(:,nNeuron));    
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

% 
% optHyp = minimize(hyp, @gp, -75, @infGaussLik, [], covFunc, likFunc, X, Y);
% [yMu,yVar] = gp(optHyp, @infGaussLik, [], covFunc, likFunc, X, Y, X);

%     [yMu(:,nNeuron),yVar(:,nNeuron)] = gp(optHyp(nNeuron), ...
%         @infGaussLik, meanFunc, covFunc, likFunc, X, Y(:,nNeuron), X);

% Find max resp and expand around this point to find optimal parameters,
% then get 1d slices through tuning array at opt params for each variable.
% Use min/max var method at these values to determine significance of each
% 1d tuning curve (min of max is below max of min, ie mean range is >
% 2std above uncertainty). Then do 1d GP on contrast phase response and
% perform the same 


% contrast phase plot
% figure,plot(yMu),hold on,plot(Y,'.')
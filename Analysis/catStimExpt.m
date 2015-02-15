function stimExpt = catStimExpt(fNames,framesPerExpt)

if ~exist('framesPerExpt','var') || isempty(framesPerExpt)
    framesPerExpt = input('How many frames per experiment? ');
end

nExpts = length(fNames);

trialOrder = [];
for nExpt = 1:nExpts
    load(fNames{nExpt}),
    trialOrder = cat(1,trialOrder,stimExpt.trialOrder);
end

offsets = (0:nExpts-1) .*...
    (framesPerExpt - numel(stimExpt.trialOrder)*stimExpt.ITI);
stimExpt.offsets = reshape(repmat(offsets,numel(stimExpt.trialOrder),1),1,[]);
stimExpt.trialOrder = trialOrder;


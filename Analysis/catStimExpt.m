function stimExpt = catStimExpt(fNames,framesPerExpt)

if ~exist('framesPerExpt','var') || isempty(framesPerExpt)
    framesPerExpt = input('How many frames per experiment? ');
end

nExpts = length(fNames);

trialOrder = [];
offsets = [];
for nExpt = 1:nExpts
    load(fNames{nExpt}),
    nTrials(nExpt) = numel(stimExpt.trialOrder);
    ITI(nExpt) = stimExpt.ITI;
    if nExpt > 1
        offsets(end+1:end+nTrials(nExpt)) = ...
            (nExpt-1) .* (framesPerExpt - nTrials(nExpt-1)*ITI(nExpt-1));
    else
        offsets(end+1:end+nTrials(nExpt)) = 0;
    end
        trialOrder = cat(1,trialOrder,stimExpt.trialOrder);
end

%offsets = (0:nExpts-1) .*...
%    (framesPerExpt - numel(stimExpt.trialOrder)*stimExpt.ITI);
%stimExpt.offsets = reshape(repmat(offsets,numel(stimExpt.trialOrder),1),1,[]);
stimExpt.offsets = offsets;
stimExpt.trialOrder = trialOrder;


function trials = repTrials(StimROIs,trialParams,stimParams,trials)

if ~exist('trials','var') || isempty(trials)
    trials = genTrial(StimROIs,1,trialParams,stimParams);
    cTrial = 0;
else
    cTrial = length(trials);
end

targList = 1:length(StimROIs.targ);
for nTarg = targList
    trials(nTarg+cTrial) = genTrial(StimROIs,nTarg,trialParams,stimParams);
end
function trialVec = vecTrials(stimExpt)

nTrials = numel(stimExpt.trialOrder);
trialVec.stimFrames = stimExpt.ITI:stimExpt.ITI:stimExpt.ITI*nTrials;

vecOrder = stimExpt.trialOrder';
trialVec.vecOrder = vecOrder(:);

for nTrial = 1:nTrials
    trial = stimExpt.trials(trialVec.vecOrder(nTrial));
    trialVec.nTarg(nTrial) = trial.nTarg;
    trialVec.nStim(nTrial) = trial.nStim;
    trialVec.dur(nTrial) = trial.stimParams.dur;
    trialVec.pockPow(nTrial) = trial.stimParams.pockPow;
    trialVec.pockPulseFreq(nTrial) = trial.stimParams.pockPulseFreq;
    trialVec.pockPulseDuty(nTrial) = trial.stimParams.pockPulseDuty;
end
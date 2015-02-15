function trialVec = vecTrials(stimExpt,frameRate)

if ~exist('frameRate','var') || isempty(frameRate)
    frameRate = 29.5475;
end

nTrials = numel(stimExpt.trialOrder);
% trialVec.stimFrames = stimExpt.ITI:stimExpt.ITI:stimExpt.ITI*nTrials;

vecOrder = stimExpt.trialOrder';
trialVec.vecOrder = vecOrder(:);
trialVec.nRepeat = ceil((1:nTrials)./size(stimExpt.trialOrder,2));

for nTrial = 1:nTrials
    trial = stimExpt.trials(trialVec.vecOrder(nTrial));
    trialVec.nTarg(nTrial) = trial.nTarg;
    trialVec.nStim(nTrial) = trial.nStim;
    trialVec.dur(nTrial) = trial.stimParams.dur;
    trialVec.pockPow(nTrial) = trial.stimParams.pockPow;
    trialVec.pockPulseFreq(nTrial) = trial.stimParams.pockPulseFreq;
    trialVec.pockPulseDuty(nTrial) = trial.stimParams.pockPulseDuty;
    stimFrameDur = round(trialVec.dur(nTrial)*frameRate);
    stimFrameRepeats = (0:trialVec.nStim-1) * round(frameRate/trial.stimFreq);
    blankingFrames = bsxfun(@plus, repmat(stimFrameRepeats,stimFrameDur,1), (0:stimFrameDur-1)');
    if isfield(stimExpt,'offsets')
        offsetFrame = stimExpt.offsets(nTrial);
    else
        offsetFrame = 0;
    end
    trialVec.stimFrames{nTrial} = nTrial * stimExpt.ITI ...
        + blankingFrames(:) + offsetFrame;
end
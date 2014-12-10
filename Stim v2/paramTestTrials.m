trialParams = [];
trialParams.sHz = sHz;
trialParams.stimFreq = 15;
trainTrial = trialParams;
stimTrial = trialParams;
trainTrial.nStim = 4;
stimTrial.nStim = 1;
[~, stimParams] = genTrial(StimROIs,1,trainTrial);

stimLong = stimParams;
stimShort = stimParams;
stimShort.dur = 15e-3;
stimPulse = stimParams;
stimPulse.pockPulseFreq = 1e4;
stimPulse.pockPulseDuty = 50;
stimWeak = stimParams;
stimWeak.pockPow = 0.9;

trials = repTrials(StimROIs,trainTrial,stimLong);
trials = repTrials(StimROIs,stimTrial,stimLong,trials);
trials = repTrials(StimROIs,trainTrial,stimShort,trials);
trials = repTrials(StimROIs,stimTrial,stimShort,trials);
trials = repTrials(StimROIs,trainTrial,stimPulse,trials);
trials = repTrials(StimROIs,stimTrial,stimPulse,trials);
trials = repTrials(StimROIs,trainTrial,stimWeak,trials);
trials = repTrials(StimROIs,stimTrial,stimWeak,trials);
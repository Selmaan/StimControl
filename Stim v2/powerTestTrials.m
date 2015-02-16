frameRate = hSI.scanFrameRate;
framePeriod = 1/frameRate;
trialParams = [];
trialParams.sHz = sHz;
trialParams.stimFreq = frameRate/3; %10
trialParams.nStim = 10;
[~, stimParams] = genTrial(StimROIs,1,trialParams);
stimParams.dur = framePeriod*2; % 60e-3

stimMax = stimParams;
stimMin = stimParams;
stimMed = stimParams;

stimMin.pockPulseFreq = 1/2e-3; %2ms per line
stimMin.pockPulseDuty = 15/512; %cell body approx 15 pix diameter in line scan

stimMed.pockPulseFreq = 1e4;
stimMed.pockPulseDuty = .2;

trials = repTrials(StimROIs,trialParams,stimMax);
trials = repTrials(StimROIs,trialParams,stimMed,trials);
trials = repTrials(StimROIs,trialParams,stimMin,trials);
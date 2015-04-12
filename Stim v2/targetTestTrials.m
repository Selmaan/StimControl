framesOn = 2;
ITI = 50;
frameRate = hSI.scanFrameRate;
framePeriod = 1/frameRate;
trialParams = [];
trialParams.sHz = sHz;
trialParams.stimFreq = frameRate/framesOn; %Ensure freq is slower than stim duration
trialParams.nStim = 1;
[~, stimParams] = genTrial(StimROIs,1,trialParams);

stimParams.dur = framePeriod*framesOn;
stimParams.pockPow = 1;
pDuty = 2;
stimParams.pockPulseFreq = stimParams.sHz/pDuty; %stimParams.sHz/3
stimParams.pockPulseDuty = 100/pDuty;  %1/3 * 100 - 1e-3

trials = repTrials(StimROIs,trialParams,stimParams);
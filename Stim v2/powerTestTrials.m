framesOn = 10;
ITI = 40;
frameRate = hSI.scanFrameRate;
framePeriod = 1/frameRate;
trialParams = [];
trialParams.sHz = sHz;
trialParams.stimFreq = frameRate/(framesOn+2); %Ensure freq is slower than stim duration
trialParams.nStim = 1;
[~, stimParams] = genTrial(StimROIs,1,trialParams);
stimParams.dur = framePeriod*framesOn;

stimHalf = stimParams;
stimHalf.pockPow = 0.85;
stimQuarter = stimParams;
stimQuarter.pockPow = 0.59;
stimEigths = stimParams;
stimEigths.pockPow = 0.38;
stimSixteenths = stimParams;
stimSixteenths.pockPow = 0.24;



trials = repTrials(StimROIs,trialParams,stimHalf);
trials = repTrials(StimROIs,trialParams,stimQuarter,trials);
trials = repTrials(StimROIs,trialParams,stimEigths,trials);
trials = repTrials(StimROIs,trialParams,stimSixteenths,trials);
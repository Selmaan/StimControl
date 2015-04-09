framesOn = 10;
ITI = 30;
frameRate = hSI.scanFrameRate;
framePeriod = 1/frameRate;
trialParams = [];
trialParams.sHz = sHz;
trialParams.stimFreq = frameRate/(framesOn+2); %Ensure freq is slower than stim duration
trialParams.nStim = 1;
[~, stimParams] = genTrial(StimROIs,1,trialParams);

stimParams.dur = framePeriod*framesOn;
stimParams.pockPow = .59;

trials = repTrials(StimROIs,trialParams,stimParams);
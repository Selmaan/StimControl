framesOn = 5;
ITI = 60;
frameRate = hSI.scanFrameRate;
framePeriod = 1/frameRate;
trialParams = [];
trialParams.sHz = sHz;
trialParams.stimFreq = frameRate/(framesOn+2);
trialParams.nStim = 1;
[~, stimParams] = genTrial(StimROIs,1,trialParams);
stimParams.dur = framePeriod*framesOn;

stimThirds = stimParams;
stimSixths = stimParams;
stimNinths = stimParams;
stimThirteens = stimParams;

stimThirds.pockPulseFreq = stimParams.sHz/3;
stimThirds.pockPulseDuty = 1/3 * 100 - 1e-3; 

stimSixths.pockPulseFreq = stimParams.sHz/6;
stimSixths.pockPulseDuty = 1/6 * 100 - 1e-3; 

stimNinths.pockPulseFreq = stimParams.sHz/9;
stimNinths.pockPulseDuty = 1/9 * 100 - 1e-3; 

stimThirteens.pockPulseFreq = stimParams.sHz/13;
stimThirteens.pockPulseDuty = 1/13 * 100 - 1e-3; 

trials = repTrials(StimROIs,trialParams,stimThirds);
trials = repTrials(StimROIs,trialParams,stimSixths,trials);
trials = repTrials(StimROIs,trialParams,stimNinths,trials);
trials = repTrials(StimROIs,trialParams,stimThirteens,trials);

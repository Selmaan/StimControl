%% Create 
powers = [15];
%stimDur = 68e-3;
framePer = hSI.hRoiManager.scanFramePeriod;
interStimDur = 2*framePer;
stimDur = 1*framePer;
trainReps = 5;

%defStimScale = [0.007 0.007];
%defStimScale = [0.006 0.006];
offsetFractions = [.5 1 1.5];

% initROIgroupsStandard,
% initROIgroupsTrainStim,
initROIgroupsResolutionMapping,
%% Create Permutation Order
numPermutations = 10;
framesITI = 100;

createPermOrderStandard,
length(listPermSeq) * framesITI,
%% Start photostim
configOnDmdStim,
tic,
fprintf('Generating Analog Output...\n');
hSI.hPhotostim.start();
fprintf('Done!\n');
toc,
source.hSI = hSI;
evt.EventName = 'onDmdStimComplete';
global dmdSeqTimer dmdSeqTimes
dmdSeqTimer = tic;
dmdSeqTimes = nan(length(listPermSeq),2);
onDemandSequencer(hSI,evt)

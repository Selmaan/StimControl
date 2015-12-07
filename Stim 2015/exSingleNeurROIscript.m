%% Create 
powers = [20];
%stimDur = 68e-3;
framePer = hSI.hRoiManager.scanFramePeriod;
interStimDur = 2*framePer;
stimDur = 1*framePer;
trainReps = 5;

defStimScale = [0.007 0.007];
defStimScale = [0.005 0.005];

% initROIgroupsStandard,
initROIgroupsTrainStim,
%% Create Permutation Order
numPermutations = 15;
framesITI = 30;

%createPermOrderRateMult,
createPermOrderStandard,
% createPermOrder_SequentialGroups,
%% Start photostim
tic,
fprintf('Generating Analog Output...\n');
hSI.hPhotostim.start();
fprintf('Done!\n');
toc,
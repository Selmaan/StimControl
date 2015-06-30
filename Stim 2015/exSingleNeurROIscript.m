%% Create 
%Stop photostim
hSI.hPhotostim.abort();

%assign First Group as Master, clear rest
baseRoiGroup = hSI.hPhotostim.stimRoiGroups(1);
hSI.hPhotostim.stimRoiGroups(2:end) = [];

% Initialize structure
tic,
fprintf('Generating RoiGroups...\n');
roiGroups = scanimage.mroi.RoiGroup.empty(0,1);

% Create default pause and park rois
hPauseRoi = scanimage.mroi.Roi();
hPauseRoi.add(0,baseRoiGroup.rois(1).scanfields(1));
hPauseRoi.scanfields.duration = 3e-3;
hParkRoi = scanimage.mroi.Roi();
hParkRoi.add(0,baseRoiGroup.rois(end).scanfields(1));

% Find valid cell rois, excluding park + pause output from cell picker
% Create new stim groups for each individually, bracketed by pause/park
listCellIDs = [];
for i=1:length(baseRoiGroup.rois)
    descrip = baseRoiGroup.rois(i).scanfields.shortDescription;
    if ~strcmp(descrip,'Stim: pause') && ~strcmp(descrip,'Stim: park')
        listCellIDs(end+1) = i;
        hRoiGroup = scanimage.mroi.RoiGroup();
        hRoiGroup.name = sprintf('Cell %d',length(listCellIDs));
        hRoi = scanimage.mroi.Roi();
        hRoi.add(0,baseRoiGroup.rois(i).scanfields(1));
        hRoi.scanfields.stimfcnhdl = @scanimage.mroi.stimulusfunctions.beatFreqSpiral;
        hRoi.scanfields.duration = 90e-3;
        hRoi.scanfields.scalingXY = [.02 .02];
        hRoiGroup.add(hPauseRoi);
        hRoiGroup.add(hRoi);
        hRoiGroup.add(hParkRoi);
        roiGroups(end+1) = hRoiGroup;
    end
end

% Add new Cell Stim Roi groups
hSI.hPhotostim.stimRoiGroups = horzcat(hSI.hPhotostim.stimRoiGroups,roiGroups);
toc,
%% Create Permutation Order
numPermutations = 300;

% Generate permutation order
allPerm = nan(length(listCellIDs),numPermutations);
for i = 1:numPermutations
    thisPerm = randperm(length(listCellIDs));
    allPerm(:,i) = thisPerm;
end
listPermSeq = allPerm(:)';

% config photostim
hSI.hPhotostim.stimulusMode = 'sequence';
hSI.hPhotostim.sequenceSelectedStimuli = ...
    listPermSeq + 1;

%% Start photostim
tic,
fprintf('Generating Analog Output...\n');
hSI.hPhotostim.start();
fprintf('Done!\n');
toc,
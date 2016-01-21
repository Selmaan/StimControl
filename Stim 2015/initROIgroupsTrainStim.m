%Stop photostim
hSI.hPhotostim.abort();

tic,
fprintf('Generating RoiGroups...\n');

%assign First Group as Master, clear rest
baseRoiGroup = hSI.hPhotostim.stimRoiGroups(1);

hSI.hPhotostim.stimRoiGroups(2:end) = [];

% Initialize structure
roiGroups = scanimage.mroi.RoiGroup.empty(0,1);

% Create default pause and park rois
hPauseRoi = baseRoiGroup.rois(1);
hPauseRoi.scanfields.duration = 1e-3;
hLongPauseRoi = duplicateStimROI(hPauseRoi);
hLongPauseRoi.scanfields.duration = interStimDur;
hParkRoi = baseRoiGroup.rois(end);

% hPauseRoi = scanimage.mroi.Roi();
% hPauseRoi.add(0,baseRoiGroup.rois(1).scanfields(1));
% hPauseRoi.scanfields.duration = 1e-3;
% hLongPauseRoi = scanimage.mroi.Roi();
% hLongPauseRoi.add(0,baseRoiGroup.rois(3).scanfields(1));
% hLongPauseRoi.scanfields.duration = interStimDur;
% hParkRoi = scanimage.mroi.Roi();
% hParkRoi.add(0,baseRoiGroup.rois(end).scanfields(1));

% Find valid cell rois, excluding park + pause output from cell picker
% Create new stim groups for each individually, bracketed by pause/park
listCellIDs = [];
for i=1:length(baseRoiGroup.rois)
    descrip = baseRoiGroup.rois(i).scanfields.shortDescription;
    if ~strcmp(descrip,'Stim: pause') && ~strcmp(descrip,'Stim: park')
        listCellIDs(end+1) = i;
        hRoiGroup = scanimage.mroi.RoiGroup();
        hRoiGroup.name = sprintf('Cell %d',length(listCellIDs));
        hRoi = baseRoiGroup.rois(i);
%         hRoi = scanimage.mroi.Roi();
%         hRoi.add(0,baseRoiGroup.rois(i).scanfields(1));
        hRoi.scanfields.stimfcnhdl = @scanimage.mroi.stimulusfunctions.beatFreqSpiral;
        hRoi.scanfields.duration = stimDur;
        thisPowerInd = mod(length(listCellIDs),length(powers)) + 1;
        hRoi.scanfields.powers = powers(thisPowerInd);
%         hRoi.scanfields.scalingXY = defStimScale;
        hRoiGroup.add(hPauseRoi);
        hRoiGroup.add(hRoi);
        for trainRep = 1:trainReps-1
            hRoiGroup.add(hLongPauseRoi);
            hRoiGroup.add(hRoi);
        end
        hRoiGroup.add(hParkRoi);
        roiGroups(end+1) = hRoiGroup;
    end
end

% Add new Cell Stim Roi groups
hSI.hPhotostim.stimRoiGroups = horzcat(hSI.hPhotostim.stimRoiGroups,roiGroups);
toc,
length(listCellIDs),
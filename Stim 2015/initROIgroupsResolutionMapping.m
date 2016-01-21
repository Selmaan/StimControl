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

% Find valid cell rois, excluding park + pause output from cell picker
% Create new stim groups for each individually, bracketed by pause/park
listCellIDs = [];
for i=1:length(baseRoiGroup.rois)
    descrip = baseRoiGroup.rois(i).scanfields.shortDescription;
    if ~strcmp(descrip,'Stim: pause') && ~strcmp(descrip,'Stim: park')
        hRoi = baseRoiGroup.rois(i);
        hRoi.scanfields.stimfcnhdl = @scanimage.mroi.stimulusfunctions.beatFreqSpiral;
        hRoi.scanfields.duration = stimDur;
        hRoi.scanfields.powers = powers;
        
        listCellIDs(end+1) = i;
        hRoiGroup = scanimage.mroi.RoiGroup();
        hRoiGroup.name = sprintf('Cell %d.0',length(listCellIDs));
        hRoiGroup.add(hPauseRoi);
        hRoiGroup.add(hRoi);
        for trainRep = 1:trainReps-1
            hRoiGroup.add(hLongPauseRoi);
            hRoiGroup.add(hRoi);
        end
        hRoiGroup.add(hParkRoi);
        roiGroups(end+1) = hRoiGroup;
        
        for offsetNum = 1:length(offsetFractions)
            offsetDirs = [0,1;1,0;0,-1;-1,0];
            for offDirNum = 1:4
                thisOffset = (hRoi.scanfields.scalingXY) .* offsetDirs(offDirNum,:) .* offsetFractions(offsetNum);
                hRoiGroup = scanimage.mroi.RoiGroup();
                hRoiGroup.name = sprintf('Cell %d.%d.%d',length(listCellIDs),offsetNum,offDirNum);
                offsetROI = duplicateStimROI(hRoi);
                offsetROI.scanfields.centerXY = offsetROI.scanfields.centerXY + thisOffset;
                
                hRoiGroup.add(hPauseRoi);
                hRoiGroup.add(offsetROI);
                for trainRep = 1:trainReps-1
                    hRoiGroup.add(hLongPauseRoi);
                    hRoiGroup.add(offsetROI);
                end
                hRoiGroup.add(hParkRoi);
                roiGroups(end+1) = hRoiGroup;
            end
        end
    end
end

% Add new Cell Stim Roi groups
hSI.hPhotostim.stimRoiGroups = horzcat(hSI.hPhotostim.stimRoiGroups,roiGroups);
toc,
length(listCellIDs),
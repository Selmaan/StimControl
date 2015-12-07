arrayfun(@(hRoiGroup)delete(hRoiGroup.rois),hSI.hPhotostim.stimRoiGroups(2:end));
arrayfun(@(hRoiGroup)hRoiGroup.delete(),hSI.hPhotostim.stimRoiGroups(2:end));
hSI.hPhotostim.stimRoiGroups(2:end) = [];
hSI.hPhotostim.sequenceSelectedStimuli = 1;


% arrayfun(@(hRoiGroup)delete(hRoiGroup.rois),hSI.hPhotostim.stimRoiGroups(2:end));
% arrayfun(@(hRoiGroup)hRoiGroup.delete(),hSI.hPhotostim.stimRoiGroups(2:end));
% delete(baseRoiGroup),
% hSI.hPhotostim.stimRoiGroups( = [];
% hSI.hPhotostim.sequenceSelectedStimuli = [];
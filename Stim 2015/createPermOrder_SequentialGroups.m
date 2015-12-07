% partition ROIs into 2 groups
listPerm = randperm(length(listCellIDs));
groupSizeROI = floor(length(listCellIDs)/2);
g1_ROIs = listPerm(1:groupSizeROI);
g2_ROIs = listPerm(groupSizeROI+1:end);

% Generate permutation order
allPerm = nan(length(listCellIDs),numPermutations);
for i = 1:numPermutations
    thisPerm = randperm(length(listCellIDs));
    allPerm(:,i) = thisPerm;
end
listPermSeq = allPerm(:)';
g1_Seq = listPermSeq;
g1_Seq(ismember(g1_Seq,g2_ROIs)) = [];
g2_Seq = listPermSeq;
g2_Seq(ismember(g2_Seq,g1_ROIs)) = [];
listPermSeq = [g1_Seq, g2_Seq];

% config photostim
hSI.hPhotostim.stimulusMode = 'sequence';
hSI.hPhotostim.sequenceSelectedStimuli = ...
    listPermSeq + 1;
hSI.hPhotostim.stimImmediately = 0;
hSI.hPhotostim.numSequences = 1;
hSI.hUserFunctions.userFunctionsCfg(1).Arguments{1} = framesITI;
hSI.hUserFunctions.userFunctionsCfg(1).Enable = 1;
hSI.hUserFunctions.userFunctionsCfg(2).Enable = 1;
length(listPermSeq) * hSI.hUserFunctions.userFunctionsCfg(1).Arguments{1},
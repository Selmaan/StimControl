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
hSI.hPhotostim.stimImmediately = 0;
hSI.hPhotostim.numSequences = 1;
hSI.hUserFunctions.userFunctionsCfg(1).Arguments{1} = framesITI;
hSI.hUserFunctions.userFunctionsCfg(1).Enable = 1;
hSI.hUserFunctions.userFunctionsCfg(2).Enable = 1;
length(listPermSeq) * hSI.hUserFunctions.userFunctionsCfg(1).Arguments{1},
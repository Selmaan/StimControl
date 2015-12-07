%Create high and low rate stim partitions
permROIs = randperm(length(listCellIDs));
highRate = permROIs(1:floor(length(listCellIDs)/2));
lowRate = permROIs(floor(length(listCellIDs)/2)+1:end);
highRateMult = 5;

% Generate permutation order
allPerm = [];
for i = 1:numPermutations
    if mod(i,highRateMult)==1
        thisPerm = randperm(length(listCellIDs));
    else
        thisPermInd = randperm(length(highRate));
        thisPerm = highRate(thisPermInd);
    end
    allPerm = [allPerm,thisPerm];
end
listPermSeq = allPerm;

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
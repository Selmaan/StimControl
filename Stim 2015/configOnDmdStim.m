% config photostim
hSI.hPhotostim.stimulusMode = 'onDemand';
hSI.hPhotostim.sequenceSelectedStimuli = ...
    listPermSeq + 1;
hSI.hPhotostim.numSequences = 1;
hSI.hPhotostim.stimImmediately = 0;
hSI.hPhotostim.allowMultipleOutputs=0;
abortFcn = find(strcmp({hSI.hUserFunctions.userFunctionsCfg.EventName},'photostimAbort'));
dmdSeqFcn = find(strcmp({hSI.hUserFunctions.userFunctionsCfg.EventName},'onDmdStimComplete'));
hSI.hUserFunctions.userFunctionsCfg(abortFcn).Enable = 1;
hSI.hUserFunctions.userFunctionsCfg(dmdSeqFcn).Enable = 1;
hSI.hUserFunctions.userFunctionsCfg(abortFcn).Arguments{1} = framesITI;

evt.EventName = 'seqStimStart';
createFrameCounter2015([],evt,framesITI);
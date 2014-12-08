function stimExpt = runExpt(stimExpt)

stimExpt.started = 1;
trialOrder = stimExpt.trialOrder;

for repeat = 1:size(trialOrder,1)
    stimExpt.cRepeat = repeat;
    for target = 1:size(trialOrder,2)
        stimExpt.cTrial = target;
        nTarget = trialOrder(repeat,target);
        % Preposition Mirrors
        offset = stimExpt.StimROIs.targ(nTarget).offset;
        writeAnalogData(stimExpt.StimControl.hStimMirrorPrep,[offset(1),offset(2)], 10, true),
        stop(stimExpt.StimControl.hStimMirrorPrep),
    
        % Load signals
        xSig = trials(nTarget).xSig;
        ySig = trials(nTarget).ySig;
        pSig = trials(nTarget).pSig;
        cfgSampClkTiming(stimExpt.StimControl.hStim, stimExpt.sHz, 'DAQmx_Val_FiniteSamps', size(xSig,1)),
        cfgSampClkTiming(stimExpt.StimControl.hStimPock, stimExpt.sHz, 'DAQmx_Val_FiniteSamps', size(xSig,1)),
        writeAnalogData(stimExpt.StimControl.hStim, [xSig,ySig], 10,false),
        writeAnalogData(stimExpt.StimControl.hStimPock, pSig, 10,false),
        
%         % prepare tasks
%         control(stimTasks.hStim,'DAQmx_Val_Task_Commit'),
%         control(stimTasks.hStimPock,'DAQmx_Val_Task_Commit'),
        
        % start tasks
        start(stimExpt.StimControl.hStim),
        start(stimExpt.StimControl.hStim),
        
        % update display
        %no display implemented yet, just print to command line
        fprintf('Repeat: %03.0f, targetNum: %03.0f, targetID: %03.0f\n',repeat,target,nTarget),
        
        % wait until triggered/complete
        %implement callback function (in fact, most of this function can be
        %written as callbacks)
        
        % unreserve resources
        stop(stimTasks.hStim),
        stop(stimTasks.hStimPock),
        control(stimTasks.hStim,'DAQmx_Val_Task_Unreserve'),
        control(stimTasks.hStimPock,'DAQmx_Val_Task_Unreserve'),
                
    end
end





stimExpt.completed = 1;
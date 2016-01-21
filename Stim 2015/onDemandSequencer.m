function onDemandSequencer(source,eventData)

    global dmdSeqTimer dmdSeqTimes
    
    hSI = source.hSI;
    hPS = hSI.hPhotostim;
    sequence = hPS.sequenceSelectedStimuli;
    sequencePtr = hPS.numSequences;
    
    switch eventData.EventName
        case 'onDmdStimComplete'
            dmdSeqTimes(sequencePtr,1) = toc(dmdSeqTimer);
            if sequencePtr > length(sequence)
                hSI.hPhotostim.abort();
                fprintf('Stim Sequence Completed! \n'),
                interSeqTimes = diff(dmdSeqTimes(2:end,2),[],1);
                figure,plot(interSeqTimes(1:end-1),'.')
            else
                hPS.onDemandStimNow(sequence(sequencePtr));
            end
            dmdSeqTimes(sequencePtr,2) = toc(dmdSeqTimer);
            sequencePtr = sequencePtr + 1;
            hPS.numSequences = sequencePtr;
    end

end


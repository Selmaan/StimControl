function onDemandSequencer(source,eventData)

    hSI = source.hSI;
    hPS = hSI.hPhotostim;
    
    persistent sequence;
    persistent sequencePtr;
    
    if isempty(sequence)
        sequence = [1 2 3 4 5];
        sequencePtr = 1;
    end
    
    switch eventData.EventName
        case 'onDmdStimComplete'
            sequencePtr = sequencePtr + 1;
            hPS.onDemandStimNow(sequence(sequencePtr));
    end

end


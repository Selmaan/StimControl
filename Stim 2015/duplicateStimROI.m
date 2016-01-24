function newROI = duplicateStimROI(StimROI)

if length(StimROI.scanfields)>1
    error('ROI contains multiple scanfields'),
end

sf = StimROI.scanfields;

newSF = scanimage.mroi.scanfield.fields.StimulusField(sf.stimfcnhdl,sf.stimparams,sf.duration,sf.repetitions,...
                sf.centerXY,sf.scalingXY,sf.rotation,sf.powers);

newROI = scanimage.mroi.Roi();
newROI.add(0,newSF);
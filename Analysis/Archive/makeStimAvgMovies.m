%% 

cd(stimExpt.acq.defaultDir),
stimCells = 1:size(stimExpt.roiCentroid,1);

%%

offsetFrames = [-10:-1,9:25];
% this was [-10:-1,8:25] in first (superficial) examples

allF = {};
for nROI = stimCells
    stimOnsets = stimExpt.exF(1,stimExpt.tV.nTarg == nROI);
    f = {};
    for thisOffset = 1:length(offsetFrames)
        f{thisOffset} = stimOnsets+offsetFrames(thisOffset);
    end
    allF = cat(2,allF,f);
end

[avgMov,dFmov] = eventTriggeredMovie(stimExpt.acq,allF);
save('stimAvgMovies','avgMov','dFmov'),
%%
nROI = 26;

frames = (nROI-1)*length(offsetFrames)+1:nROI*length(offsetFrames);
thisMov = dFmov(:,:,frames);
dispMov = bsxfun(@minus,thisMov,mean(thisMov(:,:,1:10),3));
forMovPlayer = [(thisMov-.9)*4, (dispMov+.1)*4];
implay(forMovPlayer)
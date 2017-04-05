function stimExpt = makeStimExpt(acq,expName,linFOVum,fnRes)

if nargin<4
    fnRes = cell(0);
end

if nargin<3
    linFOVum = [400, 400];
end

if nargin<2
    expName = acq.acqName;
end

stimExpt = struct;
stimExpt.name = expName;
stimExpt.acq = acq;
acqPath = acq.defaultDir;
fprintf('Select Linear Reference Image \n'),
[movNames, movPath] = uigetfile([acqPath,'\*.tif'],...
    'MultiSelect','off');
fnLin = fullfile(movPath,movNames);

stimExpt.numStimBlocks = input('How Many Stim Blocks were there? ');
% stimExpt.offsetStimBlocks = input('How many frames preceding each stim block?');
if isempty(fnRes)
    for stimBlock = 1:stimExpt.numStimBlocks
        fprintf('Select res file data for stimblock %d \n',stimBlock),
        [movNames, movPath] = uigetfile([movPath,'\*.tif'],...
            'MultiSelect','off');
        fnRes{stimBlock} = fullfile(movPath,movNames);
    end
end
stimExpt.fnRes = fnRes;
    
[stimExpt.gLin,stimExpt.rLin,stimExpt.linRA,...
    stimExpt.gRes,stimExpt.resRA,stimExpt.resHeader,...
    stimExpt.roiCentroid,stimExpt.stimGroups] = ...
    alignStimExpt(fnRes{round(length(fnRes)/2)},fnLin);

% [tV,exF] = getStimFrames(stimExpt.resHeader,stimExpt.stimGroups);
% exF = exF + stimExpt.offsetStimBlocks(1);
% tV.stimFrames = cellfun(@(x)x+stimExpt.offsetStimBlocks(1),...
%     tV.stimFrames,'UniformOutput',false);
% 
% for stimBlock = 2:stimExpt.numStimBlocks
%     [tV,exF] = appendStimBlock(fnRes{stimBlock},stimExpt.offsetStimBlocks(stimBlock),tV,exF);
% end
%     
% stimExpt.tV = tV;
% stimExpt.exF = exF;

stimExpt.xConvFactor = linFOVum(1)/stimExpt.linRA.ImageExtentInWorldX;
stimExpt.yConvFactor = linFOVum(2)/stimExpt.linRA.ImageExtentInWorldY;

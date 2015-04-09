function [trial, stimParams] = genTrial(StimROIs,nTarg,trialParams,stimParams)
%
% Generates a trial from specified paramters
%
% [trial, stimParams] = genTrial(StimROIs,nTarg,trialParams,stimParams)
%
% nTarg is the target number for this trial
% trialParams is necessary, and must include fields:
%       nTarg - the target number corresponding to StimROIs.targ
%       nStim - the number of stimulations in the trial
%       stimFreq - the frequency at which to repeat stimulation (note, function does not ensure repeats cannot overlap in time)
% stimParams is optional, and if empty will inherit sHz from trialParams

%% Input handling / error checking

if ~isfield(trialParams,'sHz'),
    error('AO sampling rate not specified, using default 1e5');
end

if ~exist('stimParams','var')
    stimParams = struct;
    stimParams.sHz = trialParams.sHz;
elseif stimParams.sHz ~= trialParams.sHz
    error('Stim and Trial sHz differ'),
end

if ~exist('nTarg','var')
    error('no target specified'),
end

if ~isfield(trialParams,'nStim')
    error('no target specified'),
end

if ~isfield(trialParams,'stimFreq')
    error('no target specified'),
end

trial = trialParams;
trial.nTarg = nTarg;
pBlankTime = 2e-3; %Time at start of trial for which pockels is blanked
%% Generate stim signals and trial timing
[stimSig,stimParams] = genStimSig(StimROIs.targ(nTarg), stimParams);

trial.dur = trial.nStim / trial.stimFreq;
trialSamples = ceil(trial.dur * trialParams.sHz);
stimSamples = length(stimSig.xSig);
stimSpacing = 0 : 1/trial.stimFreq : (trial.nStim-1)/trial.stimFreq;
stimTimes = round(stimSpacing * trialParams.sHz + 1);
pBlankOff = pBlankTime*trialParams.sHz;

%% Create trial signals

% Allocate trial sig vector w/ nans (to identify blank segments easily)
xSig = nan(trialSamples,1);
ySig = nan(trialSamples,1);
pSig = nan(trialSamples,1);

for nStim = 1:trialParams.nStim
    %Fill in each stimulation repeat's signal
    ind = (0:stimSamples-1) + stimTimes(nStim);
    xSig(ind) = stimSig.xSig;
    ySig(ind) = stimSig.ySig;
    pSig(ind) = stimSig.pockSig;
    pSig(1:pBlankOff) = 0;
end

%Append signals to pockels-blank laser and park outside FOV at trial end
trial.offset = StimROIs.targ(nTarg).offset;
xSig(end+1) = 4;
ySig(end+1) = 4;
pSig(end+1) = 0;

%Reposition mirrors at cell center and blank laser w/ pockels btw stims
xSig(isnan(xSig)) = trial.offset(1);
ySig(isnan(ySig)) = trial.offset(2);
pSig(isnan(pSig)) = 0;

trial.xSig = xSig;
trial.ySig = ySig;
trial.pSig = pSig;
trial.stimParams = stimParams;
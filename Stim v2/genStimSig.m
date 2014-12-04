function [sigs, stimParams] = genStimSig(targ,sHz,stimParams)
%
% function to generate stimulation signal for a single target. Does not
% handle prepositioning of mirrors or turning off pockels after stimulation
%
% genStimSig(targ,sHz,stimParams)

%% Error Checking and Input Handling
if ~exist('stimParams','var')
    stimParams = struct;
end

if ~exist('sHz','var')
    error('Analog Out Sampling Rate not specified'),
end

if ~isfield(stimParams, 'dur')
    stimParams.dur = 30e-3;
    fprintf('Using default stimulation duration of 30ms\n'),
end

if ~isfield(stimParams, 'rotSpeed')
    stimParams.rotSpeed = 1.5e3;
    fprintf('Using default rotation frequency of 1.5kHz\n'),
end

if ~isfield(stimParams, 'oscSpeed')
    stimParams.oscSpeed = [];
    fprintf('Using default oscillation frequency of empty (set to rot/(2*pi-2/3))\n'),
end

if ~isfield(stimParams, 'rateComp')
    stimParams.rateComp = 1;
    fprintf('Using Rate Compensation by default\n'),
end

if ~isfield(stimParams, 'pockPow')
    stimParams.pockPow = 1.5;
    fprintf('Using default pockels power of 1.5V\n'),
end

if ~isfield(stimParams, 'pockPulseFreq')
    stimParams.pockPulseFreq = 0;
    fprintf('Using no pockels pulsing by default\n'),
end

if ~isfield(stimParams, 'pockPulseDuty')
    if stimParams.pockPulseFreq > 0
        stimParams.pockPulseDuty = 0.5;
        fprintf('Using default Pockels Pulse Duty Cycle of 0.5\n'),
    else
        stimParams.pockPulseDuty = 1;
    end
end

%% Generate signals

[sigs.xSig,sigs.ySig] = genSpiralSigs(targ.diameter, targ.offset, stimParams.dur,...
    stimParams.rotSpeed, stimParams.oscSpeed, sHz, stimParams.rateComp)
nSamples = length(xSig);
sigs.pockSig = stimParams.pockPow*ones(nSamples,1);

% Create pulsed pockels signal if a positive frequency is specified
if stimParams.pockPulseFreq > 0
    t = 1/sHz:1/sHz:stimParams.dur;
    pulseTimeBase = t .* (2*pi * stimParams.pockPulseFreq);
    pockPulse = square(pulseTimeBase,stimParams.pockPulseDuty);
    sigs.pockSig = sigs.pockSig .* pockPulse;
end
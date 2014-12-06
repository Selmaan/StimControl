function [sigs, stimParams] = genStimSig(targ,stimParams)
%
% function to generate stimulation signal for a single target. Does not
% handle prepositioning of mirrors or turning off pockels after stimulation
%
% [sigs, stimParams] = genStimSig(targ,stimParams)
%
% stimParams field should contain:
% 'sHz' - AI sampling rate
% 'dur' - Stimulation duration in seconds
% 'rotSpeed' - rotational frequency of stimulation pattern
% 'oscSpeed' - amplitude oscillation frequency of stim pattern
% 'pockPow' - stimulation power, specified in raw voltage input to pockels
% 'rateComp' - whether to use rate compensation of stimulation command signal
% 'pockPulseFreq' - Frequency of pockels pulsing (0 for continuous stim)
% 'pockPulseDuty' - Duty cycle of pockels square wave pulse, in percentage

%% Error Checking and Input Handling
if ~exist('stimParams','var')
    stimParams = struct;
end

if ~isfield(stimParams, 'sHz')
    warning('Analog Out Sampling Rate not specified'),
    fprintf('Using default AO sampling rate of 1e5 Hz\n'),
    stimParams.sHz = 1e5;
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
        stimParams.pockPulseDuty = 50;
        fprintf('Using default Pockels Pulse Duty Cycle Percentage of 50\n'),
    else
        stimParams.pockPulseDuty = 100;
    end
end

%% Generate signals

[sigs.xSig,sigs.ySig] = genSpiralSigs(targ.diameter, targ.offset, stimParams.dur,...
    stimParams.rotSpeed, stimParams.oscSpeed, stimParams.sHz, stimParams.rateComp);
nSamples = length(sigs.xSig);
sigs.pockSig = stimParams.pockPow*ones(nSamples,1);

% Create pulsed pockels signal if a positive frequency is specified
if stimParams.pockPulseFreq > 0
    t = reshape(1/stimParams.sHz:1/stimParams.sHz:stimParams.dur,[],1);
    pulseTimeBase = t .* (2*pi * stimParams.pockPulseFreq);
    pockPulse = square(pulseTimeBase,stimParams.pockPulseDuty);
    sigs.pockSig = sigs.pockSig .* pockPulse;
    sigs.pockSig(sigs.pockSig<0) = 0;
end
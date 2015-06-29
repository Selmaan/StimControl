function [xx,yy] = beatFreqSpiral(tt,varargin)
% Generates a spiral trajectory where amplitude is modulated at a beat
% frequency relative to rotational phase, with a sqrt temporal profile, to
% produce a maximally and evenly area filling trajectory

%% parse inputs
inputs = scanimage.mroi.util.parseInputs(varargin);

% add optional parameters
if ~isfield(inputs,'oscFreq') || isempty(inputs.myparameter1)
   inputs.oscFreq = 1e3; % standard value for myparameter1
end

if ~isfield(inputs,'ampFreq') || isempty(inputs.myparameter2)
   inputs.ampFreq = inputs.oscFreq / (2*pi-2/3); % standard value for myparameter2
end

%% generate output

tFreq = tt * (2*pi*inputs.oscFreq);
tAmp = tt * (2*pi*inputs.ampFreq);

amp = sqrt((1-sawtooth(tAmp,1/2))/2);
cosSig=cos(tFreq);
sinSig=sin(tFreq);
xx = amp.*(cosSig+sinSig)./sqrt(2);
yy = amp.*(cosSig-sinSig)./sqrt(2);

end

%--------------------------------------------------------------------------%
% 0template.m                                                              %
% Copyright © 2015 Vidrio Technologies, LLC                                %
%                                                                          %
% ScanImage 2015 is premium software to be used under the purchased terms  %
% Code may be modified, but not redistributed without the permission       %
% of Vidrio Technologies, LLC                                              %
%--------------------------------------------------------------------------%

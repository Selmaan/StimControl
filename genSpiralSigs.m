function [xSig,ySig] = genSpiralSigs(axesDiameter, offset, dur, beamSpeed, shrinkSpeed, sRate)

%diameter scalar, offset [x y], both in volts
%beamSpeed, shrinkSpeed and sRate in Hz, dur in Sec

if isempty(shrinkSpeed)
    shrinkSpeed = beamSpeed / (2*pi);
end

t = 1/sRate:1/sRate:dur;
tFreq = t * (2*pi*beamSpeed);
tAmp = t * (2*pi*shrinkSpeed);

amp = sqrt((1-sawtooth(tAmp,1/2))/2);
xSig=cos(tFreq).*(amp*axesDiameter(1)/2) + offset(1);
ySig=sin(tFreq).*(amp*axesDiameter(2)/2) + offset(2);

xSig = reshape(xSig,length(xSig),1);
ySig = reshape(ySig,length(ySig),1);

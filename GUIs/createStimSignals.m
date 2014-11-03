function [xSig,ySig,pockSig] = createStimSignals
% --- Function to create Stimulation Signal from current parameters/ROI --%

global stimData
scanAmp = stimData.XYmult.*20/(3*stimData.imZoom);
imPix = fliplr(size(stimData.imData(:,:,1))); %Flipped so that first entry is 'fast'/image width, second is 'slow'/image height
roiRect = getPosition(stimData.stimROI);
roiCentroid = [roiRect(1) + roiRect(3)/2, roiRect(2) + roiRect(4)/2];
cellDiameter = abs(scanAmp.*roiRect(3:4)./imPix);
cellOffset = (roiCentroid-1).*(scanAmp./(imPix-1))-(scanAmp./2);

[xSig, ySig] = genSpiralSigs(cellDiameter, cellOffset,...
        stimData.stimDur*1e-3, stimData.stimRot, stimData.stimOsc, stimData.sHz, stimData.ampCompensation);
pockSig = [stimData.stimPow*ones(length(xSig)-1,1); zeros(1,1)];
%Make pockSig pulse at 50% duty cycle at 10 pulses/millisecond
pulseSamples = length(pockSig);
pulseTimeBase = linspace(0,20*pi*stimData.stimDur,pulseSamples)';
pockPulse = square(pulseTimeBase);
pockPulse(pockPulse<0) = 0;
pockSig = pockSig.*pockPulse;
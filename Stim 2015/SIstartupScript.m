fprintf('Rerouting reference clock output to digitalIODev/PFI0\n');
hResScan = hSI.hScanners{1};
hResScan.hTrig.referenceClockOut = 'PFI0';
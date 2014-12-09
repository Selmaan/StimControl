%% Counter / Stim Session Setup
%imRef = randn(512);
nFrame = 30;
scanRate = 30;

frameCount = [zeros(nFrame-1,1);1];
hFrameCounter = daq.createSession('ni');
addDigitalChannel(hFrameCounter,'ExtGalvo','Port0/Line3','OutputOnly');
hFrameCounter.IsContinuous = 1;
addClockConnection(hFrameCounter,'External','ExtGalvo/PFI0','ScanClock');
queueOutputData(hFrameCounter,repmat(frameCount,1e3,1));
hFrameCounter.Rate = scanRate;

% hStimMonitor = daq.createSession('ni');
% addDigitalChannel(hStimMonitor,'ExtGalvo','Port0/Line2','InputOnly');
% addAnalogInputChannel(hStimMonitor,'ExtGalvo',[2],'Voltage');
% lisStim = addlistener(hStimMonitor,'DataAvailable',@updateFrameCount);
% hStimMonitor.Rate = 1e4;
% hStimMonitor.DurationInSeconds = 15;
% global stimData
% stimData=[];

hStim = daq.createSession('ni');
addAnalogOutputChannel(hStim,'ExtGalvo',[0 1],'Voltage');
addAnalogOutputChannel(hStim,'si4-2',1,'Voltage');
trigStim = addTriggerConnection(hStim,'external','ExtGalvo/PFI6','StartTrigger');
trigStimPock = addTriggerConnection(hStim,'external','si4-2/PFI6','StartTrigger');
hStim.ExternalTriggerTimeout=1e3;
sHz = 2.5e5;
hStim.Rate = sHz;

hStimShutter = daq.createSession('ni');
addDigitalChannel(hStimShutter,'ExtGalvo','Port0/Line1','OutputOnly');

%% Make ROIs

%load image
roiStruct = selectROIstim(imRef,[],20/9);
nROI = length(roiStruct);

%% Make Stim Signals
pockAmp = 2;
dur = 30e-3;
beamSpeed = 1e3;
shrinkSpeed=[];%1e-2;
for cROI = 1:nROI
    [xSig, ySig] = ...
        genSpiralSigs(roiStruct(cROI).axesDiameter, roiStruct(cROI).offset,...
        dur, beamSpeed, shrinkSpeed, sHz);
    pockSig = [zeros(5,1); pockAmp*ones(length(xSig)-10,1); zeros(5,1)];
    roiStruct(cROI).sig = [xSig, ySig, pockSig];
end

%% Stim Loop
nLoop = 20;
cLoop = 0;
loopOrder = nan(nROI,nLoop);
stop(hFrameCounter);
queueOutputData(hFrameCounter,repmat(frameCount,1e3,1));
startBackground(hFrameCounter);
display(sprintf('Stimulating %d ROIs %d times at %d-frame intervals requires %d frames',...
    nROI,nLoop,nFrame,nROI*nLoop*nFrame)),
stimInterval = nan(nROI,nLoop);
stimInterval2 = nan(nROI,nLoop);

while cLoop<nLoop
    cLoop = cLoop + 1,
    loopOrder(:,cLoop) = randperm(nROI);
    cROI = 0;
    while cROI < nROI
        cROI = cROI + 1;
        permROI = loopOrder(cROI,cLoop);
        queueOutputData(hStim,roiStruct(permROI).sig),
        outputSingleScan(hStim,roiStruct(permROI).sig(1,:)),
        prepare(hStim),
        outputSingleScan(hStimShutter,1)
        stimInterval(cROI,cLoop) = hFrameCounter.ScansOutputByHardware;
        startForeground(hStim);
        stimInterval2(cROI,cLoop) = hFrameCounter.ScansOutputByHardware;
        outputSingleScan(hStimShutter,0),
    end
end

outputSingleScan(hStim,[0,0, 0]),
display(sprintf('Scans lost to loading: %d',...
    sum(stimInterval(2:end)-stimInterval2(1:end-1)))),
display(sprintf('Fraction of Scans missed: %d',...
    1-sum(stimInterval(2:end)==stimInterval2(1:end-1))/(numel(stimInterval)-1))),

filepath = 'C:\Data\Coexpression Tests\Scc7\14_06_16';
saveName = input('Name to save (empty to not) ROI perm and stim interval matrices: ','s');
if ~isempty(saveName)
    save([filepath '\' saveName],'loopOrder','stimInterval','stimInterval2','pockAmp','roiStruct') 
end
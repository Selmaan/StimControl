function varargout = StimGUI(varargin)
% STIMGUI MATLAB code for StimGUI.fig
%      STIMGUI, by itself, creates a new STIMGUI or raises the existing
%      singleton*.
%
%      H = STIMGUI returns the handle to a new STIMGUI or the handle to
%      the existing singleton*.
%
%      STIMGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STIMGUI.M with the given input arguments.
%
%      STIMGUI('Property','Value',...) creates a new STIMGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before StimGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to StimGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help StimGUI

% Last Modified by GUIDE v2.5 01-Jul-2014 12:11:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @StimGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @StimGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
end

% --- Executes just before StimGUI is made visible.
function StimGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to StimGUI (see VARARGIN)

global stimData
% imZoom stimDur stimPow stimRot stimOsc

% Choose default command line output for StimGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

[refFile,refPath] = uigetfile('.tif');
[stimData.imData,stimData.imMeta] = tiffRead([refPath refFile]);
imLim = prctile(stimData.imData(:),[1 99]);
stimData.imRef = (stimData.imData-imLim(1))/(imLim(2)-imLim(1));
axes(handles.axes1),
imshow(stimData.imRef),

stimData.imZoom = stimData.imMeta.acq.zoomFactor;
stimData.stimDur = 30;
stimData.stimPow = 1.5;
stimData.stimRot = 3e3;
stimData.stimOsc = stimData.stimRot / (2*pi-2/3);
stimData.piezoPos = 0;

stimData.stimROI = imellipse(gca, [0 0 0 0]);
stimData.ampCompensation = true;

stimData.sHz = 1e5;
sig = zeros(stimData.stimDur*1e-3*stimData.sHz,3);
createStimTasks(sig,stimData.sHz);

% UIWAIT makes StimGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end


% --- Outputs from this function are returned to the command line.
function varargout = StimGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end


% --- Executes on button press in StimParamsbutton.
function StimParamsbutton_Callback(hObject, eventdata, handles)
% hObject    handle to StimParamsbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

stimParamsGUI,
end

% --- Executes on button press in newROIbutton.
function newROIbutton_Callback(hObject, eventdata, handles)
% hObject    handle to newROIbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global stimData

delete(stimData.stimROI),

axes(handles.axes1),
stimData.stimROI = imellipse;
end

% --- Executes on button press in Stimpushbutton.
function Stimpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Stimpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

home,

global stimData stimTasks frameNum stimFrames

if strcmp('Arm Stimulation',get(handles.armButton,'String'))
    %create stim signals
    [stimData.xSig,stimData.ySig,stimData.pockSig] = createStimSignals;
    %Prepare mirrors at centroid and adjust piezo
    writeAnalogData(stimTasks.hStimMirrorPrep,[mean(stimData.xSig),mean(stimData.ySig)], 10, true),
    stop(stimTasks.hStimMirrorPrep),
    writeAnalogData(stimTasks.hStimPiezo,stimData.piezoPos/40, 10, true),
    stop(stimTasks.hStimMirrorPrep),
    %initialize / arm/ prepare tasks
    cfgSampClkTiming(stimTasks.hStim, stimData.sHz, 'DAQmx_Val_FiniteSamps', size(stimData.xSig,1)),
    cfgSampClkTiming(stimTasks.hStimPock, stimData.sHz, 'DAQmx_Val_FiniteSamps', size(stimData.xSig,1)),
    writeAnalogData(stimTasks.hStim, [stimData.xSig,stimData.ySig], 10,false),
    writeAnalogData(stimTasks.hStimPock, stimData.pockSig, 10,false),
    control(stimTasks.hStim,'DAQmx_Val_Task_Commit'),
    control(stimTasks.hStimPock,'DAQmx_Val_Task_Commit'),
    drawnow,
elseif strcmp('Armed!',get(handles.armButton,'String'))
    set(handles.armButton,'String','Arm Stimulation')
end

%Loop to be sure tasks are started before beginning of next frame
loadFrameNum = frameNum;
start(stimTasks.hStim),
start(stimTasks.hStimPock),
if frameNum ~= loadFrameNum
    abort(stimTasks.hStim),
    abort(stimTasks.hStimPock),
    display('Aborted because of Asynchronous Timing'),
    return
end
display('Stim!'),
stimFrames(end+1) = loadFrameNum + 1;
while ~isTaskDone(stimTasks.hStim) | ~isTaskDone(stimTasks.hStimPock)
    drawnow,
end
stop(stimTasks.hStim),
stop(stimTasks.hStimPock),
control(stimTasks.hStim,'DAQmx_Val_Task_Unreserve'),
control(stimTasks.hStimPock,'DAQmx_Val_Task_Unreserve'),
display('Ready...'),
end



% --- Executes on slider movement.
function gainSlider_Callback(hObject, eventdata, handles)
% hObject    handle to gainSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global stimData
imGain = 10^(round(100*get(hObject,'Value'))/100);
set(hObject,'Value',log10(imGain)),
%set(handles.gainText,'String',sprintf('Gain: %1.2d',imGain)),
stimData.roiPos = getPosition(stimData.stimROI);
axes(handles.axes1),
imshow(stimData.imRef*imGain),
stimData.stimROI = imellipse(gca,stimData.roiPos);
end

% --- Executes during object creation, after setting all properties.
function gainSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gainSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
set(hObject,'Value',0),
end

% --- Function to create Stim Tasks --- %
function createStimTasks(sig,sHz)

global stimTasks

if ~isempty(stimTasks)
    deleteStimTasks
end

stimTasks.dummy1 = dabs.ni.daqmx.Task('dummyTask1');

stimTasks.hStim = dabs.ni.daqmx.Task('X Y Stim');
createAOVoltageChan(stimTasks.hStim,'ExtGalvo',0:1,{'X Mirror','Y Mirror'},-5,5);
cfgSampClkTiming(stimTasks.hStim, sHz, 'DAQmx_Val_FiniteSamps', size(sig,1)),
cfgOutputBuffer(stimTasks.hStim, sHz),
cfgDigEdgeStartTrig(stimTasks.hStim, 'PFI0'),

stimTasks.hStimPock = dabs.ni.daqmx.Task('Stim Pockels');
createAOVoltageChan(stimTasks.hStimPock,'si4-2',1,{'Stim Pockels'},-5,5);
cfgSampClkTiming(stimTasks.hStimPock, sHz, 'DAQmx_Val_FiniteSamps', size(sig,1)),
cfgOutputBuffer(stimTasks.hStimPock, sHz),
cfgDigEdgeStartTrig(stimTasks.hStimPock, 'PFI0'),

stimTasks.hStimMirrorPrep = dabs.ni.daqmx.Task('Stim Mirror Pre-positioning');
createAOVoltageChan(stimTasks.hStimMirrorPrep,'ExtGalvo',0:1,{'X Mirror','Y Mirror'},-5,5);

stimTasks.hStimShutter = dabs.ni.daqmx.Task('Stim Shutter Toggle');
createDOChan(stimTasks.hStimShutter,'ExtGalvo','port0/line1');

stimTasks.hStimPiezo = dabs.ni.daqmx.Task('Stim Piezo Position');
createAOVoltageChan(stimTasks.hStimPiezo,'si4-2',0,{'Stim Piezo'},-5,5);

stimTasks.dummy2 = dabs.ni.daqmx.Task('dummyTask2');

end

% --- function to delete stim tasks --- %
function deleteStimTasks

global stimTasks

daqmxTaskSafeClear(stimTasks.dummy1)
daqmxTaskSafeClear(stimTasks.hStim)
daqmxTaskSafeClear(stimTasks.hStimPock)
daqmxTaskSafeClear(stimTasks.hStimMirrorPrep)
daqmxTaskSafeClear(stimTasks.hStimShutter)
daqmxTaskSafeClear(stimTasks.hStimPiezo)
daqmxTaskSafeClear(stimTasks.dummy2)

end

% --- Function to create Stimulation Signal from current parameters/ROI --%
function [xSig,ySig,pockSig] = createStimSignals

global stimData
scanAmp = 20/(3*stimData.imZoom);
roiRect = getPosition(stimData.stimROI);
roiCentroid = [roiRect(1) + roiRect(3)/2, roiRect(2) + roiRect(4)/2];
roiDiameter = (roiRect(3:4) - 1)*(scanAmp/511);
roiOffset = (roiCentroid-1)*(scanAmp/511)-(scanAmp/2);

[xSig, ySig] = genSpiralSigs(roiDiameter, roiOffset,...
        stimData.stimDur*1e-3, stimData.stimRot, stimData.stimOsc, stimData.sHz, stimData.ampCompensation);
pockSig = [stimData.stimPow*ones(length(xSig)-1,1); zeros(1,1)];
end

% --- Executes on button press in armButton.
function armButton_Callback(hObject, eventdata, handles)
% hObject    handle to armButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global stimData stimTasks

%create stim signals
[stimData.xSig,stimData.ySig,stimData.pockSig] = createStimSignals;
%Prepare Mirrors at centroid and adjust piezo position
writeAnalogData(stimTasks.hStimMirrorPrep,[mean(stimData.xSig),mean(stimData.ySig)], 10, true),
stop(stimTasks.hStimMirrorPrep),
writeAnalogData(stimTasks.hStimPiezo,stimData.piezoPos/40, 10, true),
stop(stimTasks.hStimMirrorPrep),
%Write task data
cfgSampClkTiming(stimTasks.hStim, stimData.sHz, 'DAQmx_Val_FiniteSamps', size(stimData.xSig,1)),
cfgSampClkTiming(stimTasks.hStimPock, stimData.sHz, 'DAQmx_Val_FiniteSamps', size(stimData.xSig,1)),
writeAnalogData(stimTasks.hStim, [stimData.xSig,stimData.ySig], 10,false),
writeAnalogData(stimTasks.hStimPock, stimData.pockSig, 10,false),
%Commit Tasks
control(stimTasks.hStim,'DAQmx_Val_Task_Commit'),
control(stimTasks.hStimPock,'DAQmx_Val_Task_Commit'),
set(handles.armButton,'String','Armed!')            
end            


% --- Executes on button press in resetTaskButton.
function resetTaskButton_Callback(hObject, eventdata, handles)
% hObject    handle to resetTaskButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global stimData

sig = zeros(stimData.stimDur*1e-3*stimData.sHz,3);
createStimTasks(sig,stimData.sHz);
set(handles.armButton,'String','Arm Stimulation'),
end

% --- Executes on button press in saveButton.
function saveButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global stimData

stimData.saveStimDir = uigetdir('C:\Data','Stim Data Directory');
stimData.FileBaseName = input('Name this FOV and ROI: ','s');
stimData.acqFileNumber = input('Provide Starting Acquisition Number: ');
stimData.stimFile = sprintf('%s_%03.0f',stimData.FileBaseName,stimData.acqFileNumber);
stimData.stimFullFile = fullfile(stimData.saveStimDir,stimData.stimFile);
display(sprintf(' Saving as: %s \n in: %s',stimData.stimFile,stimData.saveStimDir)),

end

% --- Executes on button press in shutterToggleButton.
function shutterToggleButton_Callback(hObject, eventdata, handles)
% hObject    handle to shutterToggleButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global stimTasks

if strcmp('Open Shutter',get(hObject,'String'))
    writeDigitalData(stimTasks.hStimShutter, 1, 10, true),
    set(hObject,'String','Close Shutter'),
    set(handles.Stimpushbutton,'BackgroundColor',[0 1 0])
elseif strcmp('Close Shutter',get(hObject,'String'))
    writeDigitalData(stimTasks.hStimShutter, 0, 10, true),
    set(hObject,'String','Open Shutter'),
    set(handles.Stimpushbutton,'BackgroundColor',[1 0 0])
end

stop(stimTasks.hStimShutter),
end

% Clears task if present, otherwise avoids error
function daqmxTaskSafeClear(task)
    try
        clkRate = task.sampClkRate; % if this call fails, the task does not exist anymore
        task.clear();
    catch ME
    end
end

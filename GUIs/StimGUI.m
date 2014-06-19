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

% Last Modified by GUIDE v2.5 18-Jun-2014 19:18:52

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


% --- Executes just before StimGUI is made visible.
function StimGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to StimGUI (see VARARGIN)

global imZoom stimDur stimPow stimRot stimOsc imData imMeta imRef stimROI hStimShutter hStimMirrorPrep

% Choose default command line output for StimGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

[refFile,refPath] = uigetfile('.tif');
[imData,imMeta] = tiffRead([refPath refFile]);
imLim = prctile(imData(:),[1 99]);
imRef = (imData-imLim(1))/(imLim(2)-imLim(1));
axes(handles.axes1),
imshow(imRef),

imZoom = imMeta.acq.zoomFactor;
stimDur = 30;
stimPow = 2;
stimRot = 1e3;
stimOsc = stimRot / (6-1/3);
stimROI = imellipse(gca, [0 0 0 0]);

%create session to control shutter
hStimShutter = daq.createSession('ni');
addDigitalChannel(hStimShutter,'ExtGalvo','Port0/Line1','OutputOnly');
%create session to preposition mirror
hStimMirrorPrep = daq.createSession('ni');
hMirrors = addAnalogOutputChannel(hStimMirrorPrep,'ExtGalvo',[0 1],'Voltage');
hMirrors(1).Range=[-5 5];
hMirrors(2).Range=[-5 5];
sHz = 1e5;
sig = zeros(stimDur*1e-3*sHz,3);
createStimTasks(sig,sHz);
deleteStimTasks;

% UIWAIT makes StimGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = StimGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in StimParamsbutton.
function StimParamsbutton_Callback(hObject, eventdata, handles)
% hObject    handle to StimParamsbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

stimParamsGUI,

% --- Executes on button press in newROIbutton.
function newROIbutton_Callback(hObject, eventdata, handles)
% hObject    handle to newROIbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global stimROI

delete(stimROI),

axes(handles.axes1),
stimROI = imellipse;


% --- Executes on button press in FrameTriggercheckbox.
function FrameTriggercheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to FrameTriggercheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of FrameTriggercheckbox


% --- Executes on button press in Stimpushbutton.
function Stimpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Stimpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

home,

global hStim hStimPock frameNum stimFrames hStimMirrorPrep

if strcmp('Arm Stimulation',get(handles.armButton,'String'))
    deleteStimTasks,

    sHz = 1e5;
    %create stim signals
    [xSig,ySig,pockSig] = createStimSignals(sHz);
    %preposition mirrors
    outputSingleScan(hStimMirrorPrep,[xSig(1),ySig(1)])
    %create stim tasks
    createStimTasks([xSig,ySig,pockSig],sHz);
    %initialize / arm/ prepare tasks
    writeAnalogData(hStim, [xSig,ySig], 60,false),
    writeAnalogData(hStimPock, pockSig, 60,false),
    control(hStim,'DAQmx_Val_Task_Commit'),
    control(hStimPock,'DAQmx_Val_Task_Commit'),
    pause(1e-3),
elseif strcmp('Armed!',get(handles.armButton,'String'))
    set(handles.armButton,'String','Arm Stimulation')
end

%Loop to be sure tasks are started before beginning of next frame
loadFrameNum = frameNum;
start(hStim),
start(hStimPock),
if frameNum ~= loadFrameNum
    abort(hStim),
    abort(hStimPock),
    display('Aborted because of Asynchronous Timing'),
    return
end
display('Stim!'),
stimFrames(end+1) = loadFrameNum + 1;
waitUntilTaskDone(hStim,1),
waitUntilTaskDone(hStimPock,1),
stop(hStim),
stop(hStimPock),
clear(hStim),
clear(hStimPock),
display('Ready...'),



% --- Executes on slider movement.
function gainSlider_Callback(hObject, eventdata, handles)
% hObject    handle to gainSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global imRef stimROI
imGain = 10^(round(100*get(hObject,'Value'))/100);
set(hObject,'Value',log10(imGain)),
%set(handles.gainText,'String',sprintf('Gain: %1.2d',imGain)),
roiPos = getPosition(stimROI);
axes(handles.axes1),
imshow(imRef*imGain),
stimROI = imellipse(gca,roiPos);

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

% --- Function to create Stim Tasks --- %
function createStimTasks(sig,sHz)

global hStim hStimPock

hStim = dabs.ni.daqmx.Task('X Y Stim');
createAOVoltageChan(hStim,'ExtGalvo',0:1,{'X Mirror','Y Mirror'},-5,5);
cfgSampClkTiming(hStim, sHz, 'DAQmx_Val_FiniteSamps', size(sig,1)),
cfgDigEdgeStartTrig(hStim, 'PFI0'),

hStimPock = dabs.ni.daqmx.Task('Stim Pockels');
createAOVoltageChan(hStimPock,'si4-2',1,{'Stim Pockels'},-5,5);
cfgSampClkTiming(hStimPock, sHz, 'DAQmx_Val_FiniteSamps', size(sig,1)),
cfgDigEdgeStartTrig(hStimPock, 'PFI0'),

% --- function to delete stim tasks --- %
function deleteStimTasks

global hStim hStimPock

if isvalid(hStim)
    abort(hStim),
    clear(hStim),
end
if isvalid(hStimPock)
    abort(hStimPock),
    clear(hStimPock),
end

% --- Function to create Stimulation Signal from current parameters/ROI --%
function [xSig,ySig,pockSig] = createStimSignals(sHz)

global imZoom stimDur stimPow stimRot stimOsc stimROI
scanAmp = 20/(3*imZoom);

roiRect = stimROI.getPosition;
roiCentroid = [roiRect(1) + roiRect(3)/2, roiRect(2) + roiRect(4)/2];
roiDiameter = (roiRect(3:4) - 1)*(scanAmp/511);
roiOffset = (roiCentroid-1)*(scanAmp/511)-(scanAmp/2);

[xSig, ySig] = genSpiralSigs(roiDiameter, roiOffset,...
        stimDur*1e-3, stimRot, stimOsc, sHz);
pockSig = [stimPow*ones(length(xSig)-1,1); zeros(1,1)];

% --- Executes on button press in armButton.
function armButton_Callback(hObject, eventdata, handles)
% hObject    handle to armButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global hStim hStimPock hStimMirrorPrep

deleteStimTasks,

sHz = 1e5;
%create stim signals
[xSig,ySig,pockSig] = createStimSignals(sHz);
outputSingleScan(hStimMirrorPrep,[xSig(1),ySig(1)])
%create stim tasks
createStimTasks([xSig,ySig,pockSig],sHz);
%Write task data
writeAnalogData(hStim, [xSig,ySig], 60,false),
writeAnalogData(hStimPock, pockSig, 60,false),
%Commit Tasks
control(hStim,'DAQmx_Val_Task_Commit'),
control(hStimPock,'DAQmx_Val_Task_Commit'),
set(handles.armButton,'String','Armed!')            
            


% --- Executes on button press in deleteTaskButton.
function deleteTaskButton_Callback(hObject, eventdata, handles)
% hObject    handle to deleteTaskButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

deleteStimTasks


% --- Executes on button press in saveButton.
function saveButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global stimFrames saveStimDir imZoom stimDur stimPow stimRot stimOsc imData imMeta stimROI

if isempty(saveStimDir)
    saveStimDir = uigetdir('C:\Data','Stim Data Directory');
end

data.stimFrames = stimFrames;
data.EllipsePos = stimROI.getPosition;
data.imZoom = imZoom;
data.stimDur = stimDur;
data.stimPow = stimPow;
data.stimRot = stimRot;
data.stimOsc = stimOsc;
data.imData = imData;
data.imMeta = imMeta;

stimFileName = input('Name this Stimulation Trial: ','s');
saveFullFile = fullfile(saveStimDir,stimFileName);

save(saveFullFile,'data')


% --- Executes on button press in shutterToggleButton.
function shutterToggleButton_Callback(hObject, eventdata, handles)
% hObject    handle to shutterToggleButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global hStimShutter

if strcmp('Open Shutter',get(hObject,'String'))
    outputSingleScan(hStimShutter,1),
    set(hObject,'String','Close Shutter'),
    set(handles.Stimpushbutton,'BackgroundColor',[0 1 0])
elseif strcmp('Close Shutter',get(hObject,'String'))
    outputSingleScan(hStimShutter,0),
    set(hObject,'String','Open Shutter'),
    set(handles.Stimpushbutton,'BackgroundColor',[1 0 0])
end

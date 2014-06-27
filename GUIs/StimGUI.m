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
stimData.stimROI = imellipse(gca, [0 0 0 0]);
stimData.ampCompensation = true;

stimData.sHz = 1e5;
sig = zeros(stimData.stimDur*1e-3*stimData.sHz,3);
createStimTasks(sig,stimData.sHz);
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
global stimData

delete(stimData.stimROI),

axes(handles.axes1),
stimData.stimROI = imellipse;

% --- Executes on button press in Stimpushbutton.
function Stimpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Stimpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

home,

global stimData hStim hStimPock frameNum stimFrames

if strcmp('Arm Stimulation',get(handles.armButton,'String'))
    deleteStimTasks,

    %create stim signals
    [stimData.xSig,stimData.ySig,stimData.pockSig] = createStimSignals(stimData.sHz);
    %Build Mirror pre-position session (TODO: eliminate this?) and pre-position mirrors 
    hStimMirrorPrep = dabs.ni.daqmx.Task('Stim Mirror Pre-positioning');
    createAOVoltageChan(hStimMirrorPrep,'ExtGalvo',0:1,{'X Mirror','Y Mirror'},-5,5);
    writeAnalogData(hStimMirrorPrep,[mean(stimData.xSig),mean(stimData.ySig)]),
    stop(hStimMirrorPrep),
    clear(hStimMirrorPrep),
    %create stim tasks
    createStimTasks([stimData.xSig,stimData.ySig,stimData.pockSig],stimData.sHz);
    %initialize / arm/ prepare tasks
    writeAnalogData(hStim, [stimData.xSig,stimData.ySig], 60,false),
    writeAnalogData(hStimPock, stimData.pockSig, 60,false),
    control(hStim,'DAQmx_Val_Task_Commit'),
    control(hStimPock,'DAQmx_Val_Task_Commit'),
    drawnow,
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
while ~isTaskDone(hStim) | ~isTaskDone(hStimPock)
    drawnow,
end
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
global stimData
imGain = 10^(round(100*get(hObject,'Value'))/100);
set(hObject,'Value',log10(imGain)),
%set(handles.gainText,'String',sprintf('Gain: %1.2d',imGain)),
stimData.roiPos = getPosition(stimData.stimROI);
axes(handles.axes1),
imshow(stimData.imRef*imGain),
stimData.stimROI = imellipse(gca,stimData.roiPos);

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

global stimData
scanAmp = 20/(3*stimData.imZoom);
roiRect = getPosition(stimData.stimROI);
roiCentroid = [roiRect(1) + roiRect(3)/2, roiRect(2) + roiRect(4)/2];
roiDiameter = (roiRect(3:4) - 1)*(scanAmp/511);
roiOffset = (roiCentroid-1)*(scanAmp/511)-(scanAmp/2);

[xSig, ySig] = genSpiralSigs(roiDiameter, roiOffset,...
        stimData.stimDur*1e-3, stimData.stimRot, stimData.stimOsc, stimData.sHz, stimData.ampCompensation);
pockSig = [stimData.stimPow*ones(length(xSig)-1,1); zeros(1,1)];

% --- Executes on button press in armButton.
function armButton_Callback(hObject, eventdata, handles)
% hObject    handle to armButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global stimData hStim hStimPock

deleteStimTasks,

%create stim signals
[stimData.xSig,stimData.ySig,stimData.pockSig] = createStimSignals(stimData.sHz);
%Build Mirror preposition session (TODO: eliminate this?) and prepare mirrors
hStimMirrorPrep = dabs.ni.daqmx.Task('Stim Mirror Pre-positioning');
createAOVoltageChan(hStimMirrorPrep,'ExtGalvo',0:1,{'X Mirror','Y Mirror'},-5,5);
writeAnalogData(hStimMirrorPrep,[mean(stimData.xSig),mean(stimData.ySig)]),
stop(hStimMirrorPrep),
clear(hStimMirrorPrep),
%create stim tasks
createStimTasks([stimData.xSig,stimData.ySig,stimData.pockSig],stimData.sHz);
%Write task data
writeAnalogData(hStim, [stimData.xSig,stimData.ySig], 60,false),
writeAnalogData(hStimPock, stimData.pockSig, 60,false),
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
set(handles.armButton,'String','Arm Stimulation'),

% --- Executes on button press in saveButton.
function saveButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global stimData stimFrames saveStimDir

if isempty(saveStimDir)
    saveStimDir = uigetdir('C:\Data','Stim Data Directory');
end

stimData.stimFrames = stimFrames;
stimData.EllipsePos = getPosition(stimData.stimROI);

stimFileName = input('Name this Stimulation Trial: ','s');
saveFullFile = fullfile(saveStimDir,stimFileName);

save(saveFullFile,'stimData')


% --- Executes on button press in shutterToggleButton.
function shutterToggleButton_Callback(hObject, eventdata, handles)
% hObject    handle to shutterToggleButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hStimShutter = dabs.ni.daqmx.Task('Stim Shutter Toggle');
createDOChan(hStimShutter,'ExtGalvo','port0/line1');

if strcmp('Open Shutter',get(hObject,'String'))
    writeDigitalData(hStimShutter, 1),
    set(hObject,'String','Close Shutter'),
    set(handles.Stimpushbutton,'BackgroundColor',[0 1 0])
elseif strcmp('Close Shutter',get(hObject,'String'))
    writeDigitalData(hStimShutter, 0),
    set(hObject,'String','Open Shutter'),
    set(handles.Stimpushbutton,'BackgroundColor',[1 0 0])
end

stop(hStimShutter),
clear(hStimShutter),
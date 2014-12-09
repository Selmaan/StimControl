function varargout = trigStimModeGUI(varargin)
% TRIGSTIMMODEGUI MATLAB code for trigStimModeGUI.fig
%      TRIGSTIMMODEGUI, by itself, creates a new TRIGSTIMMODEGUI or raises the existing
%      singleton*.
%
%      H = TRIGSTIMMODEGUI returns the handle to a new TRIGSTIMMODEGUI or the handle to
%      the existing singleton*.
%
%      TRIGSTIMMODEGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRIGSTIMMODEGUI.M with the given input arguments.
%
%      TRIGSTIMMODEGUI('Property','Value',...) creates a new TRIGSTIMMODEGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before trigStimModeGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to trigStimModeGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help trigStimModeGUI

% Last Modified by GUIDE v2.5 02-Nov-2014 18:23:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @trigStimModeGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @trigStimModeGUI_OutputFcn, ...
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


% --- Executes just before trigStimModeGUI is made visible.
function trigStimModeGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to trigStimModeGUI (see VARARGIN)

% Choose default command line output for trigStimModeGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global stimData
stimData.trigMode.nStimTrials = 10;
stimData.trigMode.nStimFrames = 90;

%create stim signals and tasks
%[stimData.xSig,stimData.ySig,stimData.pockSig] = createStimSignals;
%createCounterTasks(stimData.xSig,stimData.sHz);

% UIWAIT makes trigStimModeGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = trigStimModeGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function nStimTrials_Callback(hObject, eventdata, handles)
% hObject    handle to nStimTrials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nStimTrials as text
%        str2double(get(hObject,'String')) returns contents of nStimTrials as a double
global stimData
stimData.trigMode.nStimTrials = str2double(get(hObject,'String'));
set(handles.nFramesReq,'string',stimData.trigMode.nStimFrames*stimData.trigMode.nStimTrials + 1),

% --- Executes during object creation, after setting all properties.
function nStimTrials_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nStimTrials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nStimFrames_Callback(hObject, eventdata, handles)
% hObject    handle to nStimFrames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nStimFrames as text
%        str2double(get(hObject,'String')) returns contents of nStimFrames as a double
global stimData
stimData.trigMode.nStimFrames = str2double(get(hObject,'String'));
set(handles.nFramesReq,'string',stimData.trigMode.nStimFrames*stimData.trigMode.nStimTrials + 1),



% --- Executes during object creation, after setting all properties.
function nStimFrames_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nStimFrames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in doTrigMode.
function doTrigMode_Callback(hObject, eventdata, handles)
% hObject    handle to doTrigMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global stimData stimTasks

%create signal and tasks
[stimData.xSig,stimData.ySig,stimData.pockSig] = createStimSignals;
createCounterTasks(stimData.xSig,stimData.sHz);
%preposition mirrors and
%piezo given current parameters, and write stim signals
writeAnalogData(stimTasks.hStimMirrorPrep,[mean(stimData.xSig),mean(stimData.ySig)], 10, true),
stop(stimTasks.hStimMirrorPrep),
writeAnalogData(stimTasks.hStimPiezo,stimData.piezoPos/40, 10, true),
stop(stimTasks.hStimMirrorPrep),
cfgSampClkTiming(stimTasks.trigStim, stimData.sHz, 'DAQmx_Val_FiniteSamps', size(stimData.xSig,1)),
cfgSampClkTiming(stimTasks.hTrigPock, stimData.sHz, 'DAQmx_Val_FiniteSamps', size(stimData.xSig,1)),
writeAnalogData(stimTasks.trigStim, [stimData.xSig,stimData.ySig], 10,false),
writeAnalogData(stimTasks.hTrigPock, stimData.pockSig, 10,false),

% Starts tasks (incl. counter)
stimData.trigsDone = 0;
start(stimTasks.fCtr),
start(stimTasks.trigStim),
start(stimTasks.hTrigPock),

home,
display('Triggers Ready!'),


function createCounterTasks(sig,sHz)

global stimTasks stimData

%Specify board information
stimBoardID = 'ExtGalvoUSB';
ctrChanID = 0;
frameClockSrcTerm = 'PFI0';
dividedClockOutTerm = 'PFI1';   % leave empty if exported signal is not needed

% Determine frame counter parameters
frameInterval = stimData.trigMode.nStimFrames;
lowTicks = floor(frameInterval/2);
highTicks = ceil(frameInterval/2);
initialDelay = frameInterval;

% Delete previous tasks if they exist
if isfield(stimTasks,'dummy3')
    try
        deleteCounterTasks,
    end
end

stimTasks.dummy3 = dabs.ni.daqmx.Task('dummyTask3');

%Create Counter task
stimTasks.fCtr = dabs.ni.daqmx.Task('Frame Clock divider');
stimTasks.fCtrChan = stimTasks.fCtr.createCOPulseChanTicks(stimBoardID,ctrChanID,'Frame Clock divider',...
    frameClockSrcTerm,lowTicks,highTicks,initialDelay);
stimTasks.fCtr.cfgImplicitTiming('DAQmx_Val_ContSamps');
set(stimTasks.fCtrChan,'pulseTerm',dividedClockOutTerm);
ctrIntOutTerm = sprintf('/%sInternalOutput',stimTasks.fCtrChan.chanNamePhysical);

%Create X/Y Mirror task
stimTasks.trigStim = dabs.ni.daqmx.Task('X Y trigStim');
createAOVoltageChan(stimTasks.trigStim,stimBoardID,0:1,{'X Mirror','Y Mirror'},-5,5);
cfgSampClkTiming(stimTasks.trigStim, sHz, 'DAQmx_Val_FiniteSamps', size(sig,1)),
cfgOutputBuffer(stimTasks.trigStim, sHz),
cfgDigEdgeStartTrig(stimTasks.trigStim, ctrIntOutTerm),
registerDoneEvent(stimTasks.trigStim,@(src,evnt)trigStimDone(src,evnt)),

%Create Pockels task
stimTasks.hTrigPock = dabs.ni.daqmx.Task('Trig Pockels');
createAOVoltageChan(stimTasks.hTrigPock,'si4-2',1,{'Stim Pockels'},-5,5);
cfgSampClkTiming(stimTasks.hTrigPock, sHz, 'DAQmx_Val_FiniteSamps', size(sig,1)),
cfgOutputBuffer(stimTasks.hTrigPock, sHz),
cfgDigEdgeStartTrig(stimTasks.hTrigPock, 'PFI10'),

stimTasks.dummy4 = dabs.ni.daqmx.Task('dummyTask4');

function deleteCounterTasks

global stimTasks

daqmxTaskSafeClear(stimTasks.dummy3)
daqmxTaskSafeClear(stimTasks.fCtr)
daqmxTaskSafeClear(stimTasks.trigStim)
daqmxTaskSafeClear(stimTasks.hTrigPock)
daqmxTaskSafeClear(stimTasks.dummy4)

function trigStimDone(src,evnt)
% Stops mirror/pockels, re-arms tasks, and restarts mirror/pockels if # of
% triggers completed is less than desired. If achieved desired #, then
% stops tasks (incl. counter).
%Also writes to stimFrames variable w/ each stim
global stimData stimTasks stimFrames

stimData.trigsDone = stimData.trigsDone + 1;
stimFrames(end+1) = stimData.trigMode.nStimFrames * stimData.trigsDone;
drawnow,
stop(stimTasks.trigStim),
stop(stimTasks.hTrigPock),
control(stimTasks.trigStim,'DAQmx_Val_Task_Unreserve'),

maxTrig = stimData.trigMode.nStimTrials;
if stimData.trigsDone < maxTrig
    writeAnalogData(stimTasks.hStimMirrorPrep,[mean(stimData.xSig),mean(stimData.ySig)], 10, true),
    stop(stimTasks.hStimMirrorPrep),
    writeAnalogData(stimTasks.trigStim, [stimData.xSig,stimData.ySig], 10,false),
    writeAnalogData(stimTasks.hTrigPock, stimData.pockSig, 10,false),
    start(stimTasks.trigStim),
    start(stimTasks.hTrigPock),
    fprintf('Stim: #%03.0f\n',stimData.trigsDone);
else
    stop(stimTasks.fCtr)
    control(stimTasks.fCtr,'DAQmx_Val_Task_Unreserve'),
    control(stimTasks.trigStim,'DAQmx_Val_Task_Unreserve'),
    control(stimTasks.hTrigPock,'DAQmx_Val_Task_Unreserve'),
    fprintf('Final Stim: #%03.0f\n',stimData.trigsDone);
end



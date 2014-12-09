function varargout = stimParamsGUI(varargin)
% STIMPARAMSGUI MATLAB code for stimParamsGUI.fig
%      STIMPARAMSGUI, by itself, creates a new STIMPARAMSGUI or raises the existing
%      singleton*.
%
%      H = STIMPARAMSGUI returns the handle to a new STIMPARAMSGUI or the handle to
%      the existing singleton*.
%
%      STIMPARAMSGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STIMPARAMSGUI.M with the given input arguments.
%
%      STIMPARAMSGUI('Property','Value',...) creates a new STIMPARAMSGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before stimParamsGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to stimParamsGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help stimParamsGUI

% Last Modified by GUIDE v2.5 01-Jul-2014 12:21:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @stimParamsGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @stimParamsGUI_OutputFcn, ...
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


% --- Executes just before stimParamsGUI is made visible.
function stimParamsGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to stimParamsGUI (see VARARGIN)

% Choose default command line output for stimParamsGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global stimData
%Set all parameters to the global values
set(handles.zoomEdit,'String',stimData.imZoom)
set(handles.durEdit,'String',stimData.stimDur)
set(handles.powerEdit,'String',stimData.stimPow)
set(handles.rotEdit,'String',stimData.stimRot)
set(handles.oscEdit,'String',stimData.stimOsc)
set(handles.piezoEdit,'String',stimData.piezoPos)
% UIWAIT makes stimParamsGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = stimParamsGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function zoomEdit_Callback(hObject, eventdata, handles)
% hObject    handle to zoomEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of zoomEdit as text
%        str2double(get(hObject,'String')) returns contents of zoomEdit as a double
global stimData

stimData.imZoom = str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function zoomEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zoomEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function durEdit_Callback(hObject, eventdata, handles)
% hObject    handle to durEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of durEdit as text
%        str2double(get(hObject,'String')) returns contents of durEdit as a double
global stimData

stimData.stimDur = str2double(get(hObject,'String'));


% --- Executes during object creation, after setting all properties.
function durEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to durEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function powerEdit_Callback(hObject, eventdata, handles)
% hObject    handle to powerEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of powerEdit as text
%        str2double(get(hObject,'String')) returns contents of powerEdit as a double

global stimData

stimData.stimPow = str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function powerEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to powerEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rotEdit_Callback(hObject, eventdata, handles)
% hObject    handle to rotEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rotEdit as text
%        str2double(get(hObject,'String')) returns contents of rotEdit as a double
global stimData

stimData.stimRot = str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function rotEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rotEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function oscEdit_Callback(hObject, eventdata, handles)
% hObject    handle to oscEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of oscEdit as text
%        str2double(get(hObject,'String')) returns contents of oscEdit as a double
global stimData

stimData.stimOsc = str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function oscEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to oscEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ApplyChangespushbutton.
function ApplyChangespushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyChangespushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global stimData
%Set all parameters to the global values
stimData.imZoom = str2double(get(handles.zoomEdit,'String'));
stimData.stimDur = str2double(get(handles.durEdit,'String'));
stimData.stimPow = str2double(get(handles.powerEdit,'String'));
stimData.stimRot = str2double(get(handles.rotEdit,'String'));
oscVar = str2double(get(handles.oscEdit,'String'));
if isnan(oscVar)
    stimData.stimOsc = [];
else
    stimData.stimOsc = oscVar;
end
stimData.piezoPos = str2double(get(handles.piezoEdit,'String'));
close(handles.figure1)



function piezoEdit_Callback(hObject, eventdata, handles)
% hObject    handle to piezoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of piezoEdit as text
%        str2double(get(hObject,'String')) returns contents of piezoEdit as a double
global stimData

stimData.piezoPos = str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function piezoEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to piezoEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

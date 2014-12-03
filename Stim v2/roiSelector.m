function varargout = roiSelector(varargin)
% ROISELECTOR MATLAB code for roiSelector.fig
%      ROISELECTOR, by itself, creates a new ROISELECTOR or raises the existing
%      singleton*.
%
%      H = ROISELECTOR returns the handle to a new ROISELECTOR or the handle to
%      the existing singleton*.
%
%      ROISELECTOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ROISELECTOR.M with the given input arguments.
%
%      ROISELECTOR('Property','Value',...) creates a new ROISELECTOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before roiSelector_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to roiSelector_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help roiSelector

% Last Modified by GUIDE v2.5 03-Dec-2014 01:46:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @roiSelector_OpeningFcn, ...
                   'gui_OutputFcn',  @roiSelector_OutputFcn, ...
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


% --- Executes just before roiSelector is made visible.
function roiSelector_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to roiSelector (see VARARGIN)

% Choose default command line output for roiSelector
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global StimROIs

if isempty(StimROIs)
    StimROIs.roiNum = 1;
    StimROIs.autoNum = 1;
    [refFile, refPath] = uigetfile('.tif');
    StimROIs.imFile = fullfile(refPath, refFile);
    [StimROIs.imData,StimROIs.imMeta] = tiffRead(StimROIs.imFile,'double');
    StimROIs.imZoom = StimROIs.imMeta.acq.zoomFactor;
    StimROIs.StimCentroids = genStimCentroids(StimROIs.imFile,0);
    StimROIs.ref(:,:,1) = imadjust(StimROIs.imData(:,:,2)/2^14);
    StimROIs.ref(:,:,2) = imadjust(StimROIs.imData(:,:,1)/2^14);
    StimROIs.ref(:,:,3) = 0;    
end

axes(handles.hAxMaster),
imshow(StimROIs.ref),
axes(handles.hAxROI),
imshow(StimROIs.ref),
nextAutoROI(hObject,handles);


% UIWAIT makes roiSelector wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = roiSelector_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function nextAutoROI(hObject,handles)
% Function to examine next candidate ROI from automatic list

global StimROIs

% Adjust counters and set parameters / indices
ROIcentroid = StimROIs.StimCentroids(StimROIs.autoNum,:);
ROIwindow = ceil(StimROIs.imZoom * 10);
xROI = ROIcentroid(2) + [-ROIwindow, ROIwindow];
yROI = ROIcentroid(1) + [-ROIwindow, ROIwindow];

%xROI = StimROIs.ROIcentroid(2) + (-ROIwindow:ROIwindow);
%xROI(xROI<1) = 1; xROI(xROI>size(StimROIs.ref,2)) = size(StimROIs.ref,2);
%yROI = StimROIs.ROIcentroid(1) + (-ROIwindow:ROIwindow);
%yROI(yROI<1) = 1; yROI(yROI>size(StimROIs.ref,1)) = size(StimROIs.ref,1);
%imROI = imadjust(StimROIs.ref(yROI,xROI,1));

% Extract estimate of cell outline
redRef = StimROIs.ref(:,:,1);
theta = linspace(0, 2*pi, 300);
rho = ROIwindow:-1:1;
[thetaGrid, rhoGrid] = meshgrid(theta, rho);
[polX, polY] = pol2cart(thetaGrid, rhoGrid);
polX = polX + ROIcentroid(2);
polY = polY + ROIcentroid(1);
polX(polX<1) = 1; polX(polX>size(redRef,2)) = size(redRef,2);
polY(polY<1) = 1; polY(polY>size(redRef,1)) = size(redRef,1);
i = sub2ind(size(redRef), round(polY(:)), round(polX(:)));
ray = reshape(redRef(i), ROIwindow, []);
kRay = kmeans(ray,2);
cellRad = rho(find(kRay == kRay(end),1,'first'));

% Update plots
axes(handles.hAxMaster),
StimROIs.hPoint = impoint(gca,ROIcentroid(2),ROIcentroid(1));
setColor(StimROIs.hPoint,'b'),
%plot(ROIcentroid(2),ROIcentroid(1),'b*','markersize',10),
axes(handles.hAxROI),
xlim(xROI),
ylim(yROI),
elMin = 1+ROIcentroid([2,1])-cellRad;
elDiam = 2*cellRad;
StimROIs.hEllipse = imellipse(gca,[elMin(1) elMin(2) elDiam elDiam]);


% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
global StimROIs

switch eventdata.Key
    case 'space'
        elPos = getPosition(StimROIs.hEllipse);
        axes(handles.hAxMaster),
        StimROIs.roi(StimROIs.roiNum).hEl = imellipse(gca,elPos);
        StimROIs.roi(StimROIs.roiNum).elRadius = elPos(3:4)/2;
        StimROIs.roi(StimROIs.roiNum).elCentroid = elPos(1:2) + elPos(3:4)/2;
        StimROIs.roiNum = StimROIs.roiNum + 1;
        StimROIs.autoNum = StimROIs.autoNum + 1;
        delete(StimROIs.hPoint),
        delete(StimROIs.hEllipse),
        nextAutoROI(hObject,handles),
    case 'n'
        StimROIs.autoNum = StimROIs.autoNum + 1;
        delete(StimROIs.hPoint),
        delete(StimROIs.hEllipse),
        nextAutoROI(hObject,handles),        
end

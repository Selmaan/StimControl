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

% Last Modified by GUIDE v2.5 03-Dec-2014 11:56:50

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
    cRed = medfilt2(imNorm(StimROIs.imData(:,:,2)),[4 4]);
    cGreen = medfilt2(imNorm(StimROIs.imData(:,:,1)),[4 4]);
    StimROIs.ref(:,:,1) = adapthisteq(cRed);
    StimROIs.ref(:,:,2) = adapthisteq(cGreen);
    StimROIs.ref(:,:,3) = 0;
    StimROIs.roi = [];
    redraw = 0;
else
    redraw = 1;
end

axes(handles.hAxMaster),
imshow(StimROIs.ref);
if redraw == 1
    for nROI = 1:length(StimROIs.roi)
        elPos(1:2) = StimROIs.roi(nROI).elCentroid - StimROIs.roi(nROI).elRadius;
        elPos(3:4) = StimROIs.roi(nROI).elRadius * 2;
        StimROIs.roi(nROI).hEl = imellipse(handles.hAxMaster,elPos);
        setColor(StimROIs.roi(nROI).hEl,'k')
    end
end
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
guessCellOutline(hObject, handles, ROIcentroid);

function guessCellOutline(hObject, handles, ROIcentroid)
% Function to use an ROI centroid (from auto or mouse click) to estimate a
% cell outline

global StimROIs

ROIwindow = ceil(StimROIs.imZoom * 15);
xROI = ROIcentroid(2) + [-ROIwindow, ROIwindow];
yROI = ROIcentroid(1) + [-ROIwindow, ROIwindow];

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
        setColor(StimROIs.roi(StimROIs.roiNum).hEl,'k'),
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
    case 'return'
        elPos = getPosition(StimROIs.hEllipse);
        axes(handles.hAxMaster),
        StimROIs.roi(StimROIs.roiNum).hEl = imellipse(gca,elPos);
        setColor(StimROIs.roi(StimROIs.roiNum).hEl,'k'),
        StimROIs.roi(StimROIs.roiNum).elRadius = elPos(3:4)/2;
        StimROIs.roi(StimROIs.roiNum).elCentroid = elPos(1:2) + elPos(3:4)/2;
        StimROIs.roiNum = StimROIs.roiNum + 1;
        delete(StimROIs.hPoint),
        delete(StimROIs.hEllipse),
        nextAutoROI(hObject,handles),
    case 's'
        vCheck = input('Validate ROIs to match display? ');
        if vCheck
            % Check to see if valid ellipse remains
            for nROI = 1:StimROIs.roiNum-1
                validROI(nROI) = isvalid(StimROIs.roi(nROI).hEl);
            end
            % Eliminate invalid rois and reset the roi number counter
            StimROIs.roi = StimROIs.roi(validROI);
            StimROIs.roiNum = sum(validROI)+1;
            fprintf('ROIs Validated, current ROI num: %03.0f \n',StimROIs.roiNum),
        end
        
        % Convert pixel coordinates to volts
        StimROIs = px2vROI(StimROIs);
        % Assign variable to base (for easy access, it's global already)
        assignin('base','StimROIs',StimROIs);
        % Close GUI
        close(hObject),
end


function seedClick(hObject, handles)

global StimROIs

% get click coordinates
clickCoord = get(handles.hAxMaster, 'currentpoint');
% delete old objects
delete(StimROIs.hPoint),
delete(StimROIs.hEllipse),
% use click as initialization for next cell outline
ROIcentroid =clickCoord(1,[2, 1]);
guessCellOutline(hObject, handles, ROIcentroid);


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if gca == handles.hAxMaster
    seedClick(hObject,handles)
end
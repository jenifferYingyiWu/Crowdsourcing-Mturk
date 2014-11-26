function varargout = start_GUI(varargin)
% START_GUI MATLAB code for start_GUI.fig
%      START_GUI, by itself, creates a new START_GUI or raises the existing
%      singleton*.
%
%      H = START_GUI returns the handle to a new START_GUI or the handle to
%      the existing singleton*.
%
%      START_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in START_GUI.M with the given input arguments.
%
%      START_GUI('Property','Value',...) creates a new START_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before start_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to start_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help start_GUI

% Last Modified by GUIDE v2.5 14-Jun-2014 14:56:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @start_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @start_GUI_OutputFcn, ...
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


% --- Executes just before start_GUI is made visible.
function start_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to start_GUI (see VARARGIN)

% Choose default command line output for start_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes start_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = start_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in new_Button.
function new_Button_Callback(hObject, eventdata, handles)
% hObject    handle to new_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hideError();
s = get(findobj('Tag','new_Edit'),'String');
if exist(s,'file') || exist([s '.mat'],'file')
    set(findobj('Tag','error_Text'),'Visible','on','String',...
        'File name already exists. Please set another file name.');
else
    tmp = strfind(s,'.mat');
    if isempty(tmp)
        s = [s '.mat'];
    end
    initconf(s);
    close('start_GUI');
    crowd_GUI;
end



% --- Executes on button press in exist_Button.
function exist_Button_Callback(hObject, eventdata, handles)
% hObject    handle to exist_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hideError();
global cur_conf;
conf_set = get(findobj('Tag','conf_Menu'),'String');
index = get(findobj('Tag','conf_Menu'),'Value');
value = conf_set{index};
if strcmp(value,'No Configuration Files')
    set(findobj('Tag','error_Text'),'Visible','on','String',...
        'There are no configuration files. Please create a fresh configuration.');
    return;
else
    cur_conf = value;
end
close('start_GUI');
crowd_GUI;


function new_Edit_Callback(hObject, eventdata, handles)
% hObject    handle to new_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of new_Edit as text
%        str2double(get(hObject,'String')) returns contents of new_Edit as a double
hideError();



% --- Executes during object creation, after setting all properties.
function new_Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to new_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in conf_Menu.
function conf_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to conf_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns conf_Menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from conf_Menu
hideError();





% --- Executes during object creation, after setting all properties.
function conf_Menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to conf_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

s = getConfigFiles();
if isempty(s)
    s = {'No Configuration Files'};
    set(hObject,'String',s);
end
set(hObject,'String',s);


global cur_conf;
conf_set = get(findobj('Tag','conf_Menu'),'String');
index = 1;
value = conf_set{index};
cur_conf = value;




function hideError()
set(findobj('Tag','error_Text'),'Visible','off');

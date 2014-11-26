function varargout = crowd_GUI(varargin)
%CROWD_GUI M-file for crowd_GUI.fig
%      CROWD_GUI, by itself, creates a new CROWD_GUI or raises the existing
%      singleton*.
%
%      H = CROWD_GUI returns the handle to a new CROWD_GUI or the handle to
%      the existing singleton*.
%
%      CROWD_GUI('Property','Value',...) creates a new CROWD_GUI using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to crowd_GUI_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      CROWD_GUI('CALLBACK') and CROWD_GUI('CALLBACK',hObject,...) call the
%      local function named CALLBACK in CROWD_GUI.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help crowd_GUI

% Last Modified by GUIDE v2.5 30-Jun-2014 00:13:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @crowd_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @crowd_GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before crowd_GUI is made visible.
function crowd_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for crowd_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes crowd_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = crowd_GUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Run_Button.
function Run_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Run_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global cur_conf;
run_conf(cur_conf);


% --- Executes during object creation, after setting all properties.
function Run_Button_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Run_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on selection change in classifier_Menu.
function classifier_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to classifier_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns classifier_Menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from classifier_Menu
hideMessage();

% --- Executes during object creation, after setting all properties.
function classifier_Menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to classifier_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
loadconf;
set(hObject,'String',['Not Set', classifiers]);




function field1_Edit_Callback(hObject, eventdata, handles)
% hObject    handle to field1_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of field1_Edit as text
%        str2double(get(hObject,'String')) returns contents of field1_Edit as a double
hideMessage();

% --- Executes during object creation, after setting all properties.
function field1_Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to field1_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function field2_Edit_Callback(hObject, eventdata, handles)
% hObject    handle to field2_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of field2_Edit as text
%        str2double(get(hObject,'String')) returns contents of field2_Edit as a double
hideMessage();

% --- Executes during object creation, after setting all properties.
function field2_Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to field2_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function field3_Edit_Callback(hObject, eventdata, handles)
% hObject    handle to field3_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of field3_Edit as text
%        str2double(get(hObject,'String')) returns contents of field3_Edit as a double
hideMessage();

% --- Executes during object creation, after setting all properties.
function field3_Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to field3_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function field4_Edit_Callback(hObject, eventdata, handles)
% hObject    handle to field4_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of field4_Edit as text
%        str2double(get(hObject,'String')) returns contents of field4_Edit as a double
hideMessage();

% --- Executes during object creation, after setting all properties.
function field4_Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to field4_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function field5_Edit_Callback(hObject, eventdata, handles)
% hObject    handle to field5_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of field5_Edit as text
%        str2double(get(hObject,'String')) returns contents of field5_Edit as a double
hideMessage();

% --- Executes during object creation, after setting all properties.
function field5_Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to field5_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function field6_Edit_Callback(hObject, eventdata, handles)
% hObject    handle to field6_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of field6_Edit as text
%        str2double(get(hObject,'String')) returns contents of field6_Edit as a double
hideMessage();

% --- Executes during object creation, after setting all properties.
function field6_Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to field6_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in alSaveOne_Button.
function alSaveOne_Button_Callback(hObject, eventdata, handles)
% hObject    handle to alSaveOne_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
loadconf;
hideAllMessage();
set(findobj('Tag','alMessage_Text'),'Visible','on');
title = get(findobj('Tag','ALO'),'Title');
C = strsplit(title,' Options');
save_al = C(1);
save_al = save_al{1};

classifier_set = get(findobj('Tag','classifier_Menu'),'String');
index = get(findobj('Tag','classifier_Menu'),'Value');
value = classifier_set{index};
if strcmp(value,'Not Set')
    value = '';
end

tmp_struct = struct;
tmp_struct.classifier = value;
for i=1:6
   if strcmp(get(findobj('Tag',['field' num2str(i) '_Text']),'Visible'),'on')
       field_name = get(findobj('Tag',['field' num2str(i) '_Text']),'String');
       field_name = field_name(1:length(field_name)-1);
       field_value = get(findobj('Tag',['field' num2str(i) '_Edit']),'String');
       tmp_struct.(field_name) = field_value;
   else
       break;
   end
end

al_info_map.(save_al) = tmp_struct;
saveconf;


% --- Executes on button press in alSaveAll_Button.
function alSaveAll_Button_Callback(hObject, eventdata, handles)
% hObject    handle to alSaveAll_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
loadconf;
hideAllMessage();
set(findobj('Tag','alMessage_Text'),'Visible','on');
classifier_set = get(findobj('Tag','classifier_Menu'),'String');
index = get(findobj('Tag','classifier_Menu'),'Value');
value = classifier_set{index};
if strcmp(value,'Not Set')
    value = '';
end


fieldname_set = als_Icare;
for i=1:length(fieldname_set)
    al_info_map.(fieldname_set{i}).classifier = value;
end

saveconf;


% --- Executes on button press in alSaveAllNotset_Button.
function alSaveAllNotset_Button_Callback(hObject, eventdata, handles)
% hObject    handle to alSaveAllNotset_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
loadconf;
hideAllMessage();
set(findobj('Tag','alMessage_Text'),'Visible','on');
classifier_set = get(findobj('Tag','classifier_Menu'),'String');
index = get(findobj('Tag','classifier_Menu'),'Value');
value = classifier_set{index};
if strcmp(value,'Not Set')
    value = '';
end

fieldname_set = als_Icare;
for i=1:length(fieldname_set)
    if isempty(al_info_map.(fieldname_set{i}).classifier)
        al_info_map.(fieldname_set{i}).classifier = value;
    end
end

title = get(findobj('Tag','ALO'),'Title');
C = strsplit(title,' Options');
save_al = C(1);
save_al = save_al{1};
al_info_map.(save_al).classifier = value;

saveconf;

% --- Executes on button press in absolute_budgetPerStep_Check.
function absolute_budgetPerStep_Check_Callback(hObject, eventdata, handles)
% hObject    handle to absolute_budgetPerStep_Check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of absolute_budgetPerStep_Check
hideMessage();

% --- Executes on button press in absolute_budgetReportingFrequency_Check.
function absolute_budgetReportingFrequency_Check_Callback(hObject, eventdata, handles)
% hObject    handle to absolute_budgetReportingFrequency_Check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of absolute_budgetReportingFrequency_Check
hideMessage();


function whatYouCanSee_Edit_Callback(hObject, eventdata, handles)
% hObject    handle to whatYouCanSee_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of whatYouCanSee_Edit as text
%        str2double(get(hObject,'String')) returns contents of whatYouCanSee_Edit as a double
hideMessage();

% --- Executes during object creation, after setting all properties.
function whatYouCanSee_Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to whatYouCanSee_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function budgetReportingFrequency_Edit_Callback(hObject, eventdata, handles)
% hObject    handle to budgetReportingFrequency_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of budgetReportingFrequency_Edit as text
%        str2double(get(hObject,'String')) returns contents of budgetReportingFrequency_Edit as a double
hideMessage();

% --- Executes during object creation, after setting all properties.
function budgetReportingFrequency_Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to budgetReportingFrequency_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in absolute_totalBudget_Check.
function absolute_totalBudget_Check_Callback(hObject, eventdata, handles)
% hObject    handle to absolute_totalBudget_Check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of absolute_totalBudget_Check
hideMessage();


function totalBudget_Edit_Callback(hObject, eventdata, handles)
% hObject    handle to totalBudget_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of totalBudget_Edit as text
%        str2double(get(hObject,'String')) returns contents of totalBudget_Edit as a double
hideMessage();

% --- Executes during object creation, after setting all properties.
function totalBudget_Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to totalBudget_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function budgetPerStep_Edit_Callback(hObject, eventdata, handles)
% hObject    handle to budgetPerStep_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of budgetPerStep_Edit as text
%        str2double(get(hObject,'String')) returns contents of budgetPerStep_Edit as a double
hideMessage();

% --- Executes during object creation, after setting all properties.
function budgetPerStep_Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to budgetPerStep_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function strategy_Edit_Callback(hObject, eventdata, handles)
% hObject    handle to strategy_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of strategy_Edit as text
%        str2double(get(hObject,'String')) returns contents of strategy_Edit as a double
hideMessage();

% --- Executes during object creation, after setting all properties.
function strategy_Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to strategy_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function repFactor_Edit_Callback(hObject, eventdata, handles)
% hObject    handle to repFactor_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of repFactor_Edit as text
%        str2double(get(hObject,'String')) returns contents of repFactor_Edit as a double
hideMessage();

% --- Executes during object creation, after setting all properties.
function repFactor_Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to repFactor_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in dsSaveOne_Button.
function dsSaveOne_Button_Callback(hObject, eventdata, handles)
% hObject    handle to dsSaveOne_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
loadconf;
hideMessage();
set(findobj('Tag','dsMessage_Text'),'Visible','on');
title = get(findobj('Tag','DSO'),'Title');
C = strsplit(title,' Options');
save_ds = C(1);
save_ds = save_ds{1};

strategy = str2double(get(findobj('Tag','strategy_Edit'),'String'));
repFactor = str2double(get(findobj('Tag','repFactor_Edit'),'String'));

absolute_whatYouCanSee = get(findobj('Tag','absolute_whatYouCanSee_Check'),'Value');
absolute_budgetPerStep = get(findobj('Tag','absolute_budgetPerStep_Check'),'Value');
absolute_budgetReportingFrequency = get(findobj('Tag','absolute_budgetReportingFrequency_Check'),'Value');
absolute_totalBudget = get(findobj('Tag','absolute_totalBudget_Check'),'Value');
whatYouCanSee = str2double(get(findobj('Tag','whatYouCanSee_Edit'),'String'));
budgetPerStep = str2double(get(findobj('Tag','budgetPerStep_Edit'),'String'));
budgetReportingFrequency = str2double(get(findobj('Tag','budgetReportingFrequency_Edit'),'String'));
totalBudget = str2double(get(findobj('Tag','totalBudget_Edit'),'String'));


ds_info_map.(save_ds) = struct('absolute_whatYouCanSee', absolute_whatYouCanSee, 'whatYouCanSee', whatYouCanSee, ...
    'absolute_budgetPerStep', absolute_budgetPerStep, 'budgetPerStep', budgetPerStep, 'absolute_budgetReportingFrequency',...
    absolute_budgetReportingFrequency, 'budgetReportingFrequency', budgetReportingFrequency, 'absolute_totalBudget', absolute_totalBudget,...
    'totalBudget', totalBudget, 'repFactor', repFactor, 'strategy', strategy);
    
saveconf;
    
    

% --- Executes on button press in dsSaveAll_Button.
function dsSaveAll_Button_Callback(hObject, eventdata, handles)
% hObject    handle to dsSaveAll_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
loadconf;
hideMessage();

strategy = str2double(get(findobj('Tag','strategy_Edit'),'String'));
repFactor = str2double(get(findobj('Tag','repFactor_Edit'),'String'));

absolute_whatYouCanSee = get(findobj('Tag','absolute_whatYouCanSee_Check'),'Value');
absolute_budgetPerStep = get(findobj('Tag','absolute_budgetPerStep_Check'),'Value');
absolute_budgetReportingFrequency = get(findobj('Tag','absolute_budgetReportingFrequency_Check'),'Value');
absolute_totalBudget = get(findobj('Tag','absolute_totalBudget_Check'),'Value');
whatYouCanSee = str2double(get(findobj('Tag','whatYouCanSee_Edit'),'String'));
budgetPerStep = str2double(get(findobj('Tag','budgetPerStep_Edit'),'String'));
budgetReportingFrequency = str2double(get(findobj('Tag','budgetReportingFrequency_Edit'),'String'));
totalBudget = str2double(get(findobj('Tag','totalBudget_Edit'),'String'));


for i=1:length(dss_Icare)
    ds_info_map.(dss_Icare{i}) = struct('absolute_whatYouCanSee', absolute_whatYouCanSee, 'whatYouCanSee', whatYouCanSee, ...
    'absolute_budgetPerStep', absolute_budgetPerStep, 'budgetPerStep', budgetPerStep, 'absolute_budgetReportingFrequency',...
    absolute_budgetReportingFrequency, 'budgetReportingFrequency', budgetReportingFrequency, 'absolute_totalBudget', absolute_totalBudget,...
    'totalBudget', totalBudget, 'repFactor', repFactor, 'strategy', strategy);
end
saveconf;



% --- Executes on button press in dsSaveAllNotset_Button.
function dsSaveAllNotset_Button_Callback(hObject, eventdata, handles)
% hObject    handle to dsSaveAllNotset_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
loadconf;
hideMessage();

strategy = str2double(get(findobj('Tag','strategy_Edit'),'String'));
repFactor = str2double(get(findobj('Tag','repFactor_Edit'),'String'));

absolute_whatYouCanSee = get(findobj('Tag','absolute_whatYouCanSee_Check'),'Value');
absolute_budgetPerStep = get(findobj('Tag','absolute_budgetPerStep_Check'),'Value');
absolute_budgetReportingFrequency = get(findobj('Tag','absolute_budgetReportingFrequency_Check'),'Value');
absolute_totalBudget = get(findobj('Tag','absolute_totalBudget_Check'),'Value');
whatYouCanSee = str2double(get(findobj('Tag','whatYouCanSee_Edit'),'String'));
budgetPerStep = str2double(get(findobj('Tag','budgetPerStep_Edit'),'String'));
budgetReportingFrequency = str2double(get(findobj('Tag','budgetReportingFrequency_Edit'),'String'));
totalBudget = str2double(get(findobj('Tag','totalBudget_Edit'),'String'));

for i=1:length(dss_Icare)
    if isnan(ds_info_map.(dss_Icare{i}).whatYouCanSee)
        ds_info_map.(dss_Icare{i}).whatYouCanSee = whatYouCanSee;
    end
    if isnan(ds_info_map.(dss_Icare{i}).budgetPerStep)
        ds_info_map.(dss_Icare{i}).budgetPerStep = budgetPerStep;
    end
	if isnan(ds_info_map.(dss_Icare{i}).budgetReportingFrequency)
        ds_info_map.(dss_Icare{i}).budgetReportingFrequency = budgetReportingFrequency;
    end
    if isnan(ds_info_map.(dss_Icare{i}).totalBudget)
        ds_info_map.(dss_Icare{i}).totalBudget = totalBudget;
    end
    if isnan(ds_info_map.(dss_Icare{i}).strategy)
        ds_info_map.(dss_Icare{i}).strategy = strategy;
    end
	if isnan(ds_info_map.(dss_Icare{i}).repFactor)
        ds_info_map.(dss_Icare{i}).repFactor = repFactor;
    end
end

title = get(findobj('Tag','DSO'),'Title');
C = strsplit(title,' Options');
save_ds = C(1);
save_ds = save_ds{1};

ds_info_map.(save_ds) = struct('absolute_whatYouCanSee', absolute_whatYouCanSee, 'whatYouCanSee', whatYouCanSee, ...
    'absolute_budgetPerStep', absolute_budgetPerStep, 'budgetPerStep', budgetPerStep, 'absolute_budgetReportingFrequency',...
    absolute_budgetReportingFrequency, 'budgetReportingFrequency', budgetReportingFrequency, 'absolute_totalBudget', absolute_totalBudget,...
    'totalBudget', totalBudget, 'repFactor', repFactor, 'strategy', strategy);

saveconf;

% --- Executes on button press in dsAdd_Button.
function dsAdd_Button_Callback(hObject, eventdata, handles)
% hObject    handle to dsAdd_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hideMessage();
hideDSInfo();
loadconf;
h_from = findobj('Tag','dss_available_Box');
h_to = findobj('Tag','dss_Icare_Box');
sets_from = get(h_from,'String');
index_from = get(h_from,'Value');

if ~isempty(sets_from)
    value = sets_from{index_from};
    sets_to = get(h_to, 'String');
    sets_to = [sets_to; {value}];
    sets_from(index_from) = [];
    if(index_from > length(sets_from))
        if ~isempty(sets_from)
            set(h_from,'Value',index_from - 1,'String',sets_from);
        else
            set(h_from,'Value',1,'String',sets_from);
        end
    else
        set(h_from,'String',sets_from);
    end
    
    if length(sets_to) == 1
        set(h_to,'Value',1,'String',sets_to);
    else
        set(h_to,'String',sets_to);
    end
end

dss_available = get(findobj('Tag','dss_available_Box'),'String');
dss_Icare = get(findobj('Tag','dss_Icare_Box'),'String');
dss_available = transpose(dss_available);
dss_Icare = transpose(dss_Icare);
saveconf;

% --- Executes on button press in dsRemove_Button.
function dsRemove_Button_Callback(hObject, eventdata, handles)
% hObject    handle to dsRemove_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hideMessage();
hideDSInfo();
loadconf;
h_from = findobj('Tag','dss_Icare_Box');
h_to = findobj('Tag','dss_available_Box');
sets_from = get(h_from,'String');
index_from = get(h_from,'Value');

if ~isempty(sets_from)
    value = sets_from{index_from};
    sets_to = get(h_to, 'String');
    sets_to = [sets_to; {value}];
    sets_from(index_from) = [];
    if(index_from > length(sets_from))
        if ~isempty(sets_from)
            set(h_from,'Value',index_from - 1,'String',sets_from);
        else
            set(h_from,'Value',1,'String',sets_from);
        end
    else
        set(h_from,'String',sets_from);
    end
    
    if length(sets_to) == 1
        set(h_to,'Value',1,'String',sets_to);
    else
        set(h_to,'String',sets_to);
    end
end

dss_available = get(findobj('Tag','dss_available_Box'),'String');
dss_Icare = get(findobj('Tag','dss_Icare_Box'),'String');
dss_available = transpose(dss_available);
dss_Icare = transpose(dss_Icare);
saveconf;

% --- Executes on selection change in dss_available_Box.
function dss_available_Box_Callback(hObject, eventdata, handles)
% hObject    handle to dss_available_Box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns dss_available_Box contents as cell array
%        contents{get(hObject,'Value')} returns selected item from dss_available_Box
hideMessage();
sets = get(hObject,'String');
index = get(hObject,'Value');
if ~isempty(sets)
    hideDSInfo();
	value = sets{index};
	set(findobj('Tag','DSO'),'Title',[value ' Options']);
    setDSInfo(value);
    setDSMessage(value);
end

% --- Executes during object creation, after setting all properties.
function dss_available_Box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dss_available_Box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
loadconf;
set(hObject,'String',dss_available);


% --- Executes on selection change in dss_Icare_Box.
function dss_Icare_Box_Callback(hObject, eventdata, handles)
% hObject    handle to dss_Icare_Box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns dss_Icare_Box contents as cell array
%        contents{get(hObject,'Value')} returns selected item from dss_Icare_Box
hideMessage();
sets = get(hObject,'String');
index = get(hObject,'Value');
if ~isempty(sets)
    showDSInfo();
	value = sets{index};
	set(findobj('Tag','DSO'),'Title',[value ' Options']); 
    setDSInfo(value);
    setDSMessage(value);
end

% --- Executes during object creation, after setting all properties.
function dss_Icare_Box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dss_Icare_Box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
loadconf;
set(hObject,'String',dss_Icare);


% --- Executes on button press in dsAddAll_Button.
function dsAddAll_Button_Callback(hObject, eventdata, handles)
% hObject    handle to dsAddAll_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hideMessage();
hideDSInfo();
loadconf;
h_from = findobj('Tag','dss_available_Box');
h_to = findobj('Tag','dss_Icare_Box');

while(1)
    sets_from = get(h_from,'String');
    index_from = get(h_from,'Value');

    if ~isempty(sets_from)
        value = sets_from{index_from};
        sets_to = get(h_to, 'String');
        sets_to = [sets_to; {value}];
        sets_from(index_from) = [];
        if(index_from > length(sets_from))
            if ~isempty(sets_from)
                set(h_from,'Value',index_from - 1,'String',sets_from);
            else
                set(h_from,'Value',1,'String',sets_from);
            end
        else
            set(h_from,'String',sets_from);
        end

        if length(sets_to) == 1
            set(h_to,'Value',1,'String',sets_to);
        else
            set(h_to,'String',sets_to);
        end
    else
        break;
    end

end
dss_available = get(findobj('Tag','dss_available_Box'),'String');
dss_Icare = get(findobj('Tag','dss_Icare_Box'),'String');
dss_available = transpose(dss_available);
dss_Icare = transpose(dss_Icare);
saveconf;

% --- Executes on button press in dsRemoveAll_Button.
function dsRemoveAll_Button_Callback(hObject, eventdata, handles)
% hObject    handle to dsRemoveAll_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hideMessage();
hideDSInfo();
loadconf;
h_from = findobj('Tag','dss_Icare_Box');
h_to = findobj('Tag','dss_available_Box');

while(1)
    sets_from = get(h_from,'String');
    index_from = get(h_from,'Value');

    if ~isempty(sets_from)
        value = sets_from{index_from};
        sets_to = get(h_to, 'String');
        sets_to = [sets_to; {value}];
        sets_from(index_from) = [];
        if(index_from > length(sets_from))
            if ~isempty(sets_from)
                set(h_from,'Value',index_from - 1,'String',sets_from);
            else
                set(h_from,'Value',1,'String',sets_from);
            end
        else
            set(h_from,'String',sets_from);
        end

        if length(sets_to) == 1
            set(h_to,'Value',1,'String',sets_to);
        else
            set(h_to,'String',sets_to);
        end
    else
        break;
    end

end
dss_available = get(findobj('Tag','dss_available_Box'),'String');
dss_Icare = get(findobj('Tag','dss_Icare_Box'),'String');
dss_available = transpose(dss_available);
dss_Icare = transpose(dss_Icare);
saveconf;

% --- Executes on button press in alRemove_Button.
function alRemove_Button_Callback(hObject, eventdata, handles)
% hObject    handle to alRemove_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hideMessage();
hideALInfo();
loadconf;
h_from = findobj('Tag','als_Icare_Box');
h_to = findobj('Tag','als_available_Box');
sets_from = get(h_from,'String');
index_from = get(h_from,'Value');

if ~isempty(sets_from)
    value = sets_from{index_from};
    sets_to = get(h_to, 'String');
    sets_to = [sets_to; {value}];
    sets_from(index_from) = [];
    if(index_from > length(sets_from))
        if ~isempty(sets_from)
            set(h_from,'Value',index_from - 1,'String',sets_from);
        else
            set(h_from,'Value',1,'String',sets_from);
        end
    else
        set(h_from,'String',sets_from);
    end
    
    if length(sets_to) == 1
        set(h_to,'Value',1,'String',sets_to);
    else
        set(h_to,'String',sets_to);
    end
end

als_available = get(findobj('Tag','als_available_Box'),'String');
als_Icare = get(findobj('Tag','als_Icare_Box'),'String');
als_available = transpose(als_available);
als_Icare = transpose(als_Icare);
saveconf;


% --- Executes on button press in alAdd_Button.
function alAdd_Button_Callback(hObject, eventdata, handles)
% hObject    handle to alAdd_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hideMessage();
hideALInfo();
loadconf;
h_from = findobj('Tag','als_available_Box');
h_to = findobj('Tag','als_Icare_Box');
sets_from = get(h_from,'String');
index_from = get(h_from,'Value');

if ~isempty(sets_from)
    value = sets_from{index_from};
    sets_to = get(h_to, 'String');
    sets_to = [sets_to; {value}];
    sets_from(index_from) = [];
    if(index_from > length(sets_from))
        if ~isempty(sets_from)
            set(h_from,'Value',index_from - 1,'String',sets_from);
        else
            set(h_from,'Value',1,'String',sets_from);
        end
    else
        set(h_from,'String',sets_from);
    end
    
    if length(sets_to) == 1
        set(h_to,'Value',1,'String',sets_to);
    else
        set(h_to,'String',sets_to);
    end
end

als_available = get(findobj('Tag','als_available_Box'),'String');
als_Icare = get(findobj('Tag','als_Icare_Box'),'String');
als_available = transpose(als_available);
als_Icare = transpose(als_Icare);
saveconf;


% --- Executes on button press in alAddAll_Button.
function alAddAll_Button_Callback(hObject, eventdata, handles)
% hObject    handle to alAddAll_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hideMessage();
hideALInfo();
loadconf;
h_from = findobj('Tag','als_available_Box');
h_to = findobj('Tag','als_Icare_Box');

while(1)
    sets_from = get(h_from,'String');
    index_from = get(h_from,'Value');

    if ~isempty(sets_from)
        value = sets_from{index_from};
        sets_to = get(h_to, 'String');
        sets_to = [sets_to; {value}];
        sets_from(index_from) = [];
        if(index_from > length(sets_from))
            if ~isempty(sets_from)
                set(h_from,'Value',index_from - 1,'String',sets_from);
            else
                set(h_from,'Value',1,'String',sets_from);
            end
        else
            set(h_from,'String',sets_from);
        end

        if length(sets_to) == 1
            set(h_to,'Value',1,'String',sets_to);
        else
            set(h_to,'String',sets_to);
        end
    else
        break;
    end
end

als_available = get(findobj('Tag','als_available_Box'),'String');
als_Icare = get(findobj('Tag','als_Icare_Box'),'String');
als_available = transpose(als_available);
als_Icare = transpose(als_Icare);
saveconf;


% --- Executes on button press in alRemoveAll_Button.
function alRemoveAll_Button_Callback(hObject, eventdata, handles)
% hObject    handle to alRemoveAll_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hideMessage();
hideALInfo();
loadconf;
h_from = findobj('Tag','als_Icare_Box');
h_to = findobj('Tag','als_available_Box');

while(1)
    sets_from = get(h_from,'String');
    index_from = get(h_from,'Value');

    if ~isempty(sets_from)
        value = sets_from{index_from};
        sets_to = get(h_to, 'String');
        sets_to = [sets_to; {value}];
        sets_from(index_from) = [];
        if(index_from > length(sets_from))
            if ~isempty(sets_from)
                set(h_from,'Value',index_from - 1,'String',sets_from);
            else
                set(h_from,'Value',1,'String',sets_from);
            end
        else
            set(h_from,'String',sets_from);
        end

        if length(sets_to) == 1
            set(h_to,'Value',1,'String',sets_to);
        else
            set(h_to,'String',sets_to);
        end
    else
        break;
    end
end

als_available = get(findobj('Tag','als_available_Box'),'String');
als_Icare = get(findobj('Tag','als_Icare_Box'),'String');
als_available = transpose(als_available);
als_Icare = transpose(als_Icare);
saveconf;


% --- Executes on selection change in als_Icare_Box.
function als_Icare_Box_Callback(hObject, eventdata, handles)
% hObject    handle to als_Icare_Box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns als_Icare_Box contents as cell array
%        contents{get(hObject,'Value')} returns selected item from als_Icare_Box
hideMessage();
sets = get(hObject,'String');
index = get(hObject,'Value');
if ~isempty(sets)
	showALInfo();
	value = sets{index};
	set(findobj('Tag','ALO'),'Title',[value ' Options']);
    setALInfo(value);
    setALMessage(value);
end



% --- Executes during object creation, after setting all properties.
function als_Icare_Box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to als_Icare_Box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
loadconf;
set(hObject,'String',als_Icare);


% --- Executes on selection change in als_available_Box.
function als_available_Box_Callback(hObject, eventdata, handles)
% hObject    handle to als_available_Box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns als_available_Box contents as cell array
%        contents{get(hObject,'Value')} returns selected item from als_available_Box
hideMessage();
sets = get(hObject,'String');
index = get(hObject,'Value');
if ~isempty(sets)
    hideALInfo();
	value = sets{index};
	set(findobj('Tag','ALO'),'Title',[value ' Options']);
    setALInfo(value);
    setALMessage(value);
end

% --- Executes during object creation, after setting all properties.
function als_available_Box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to als_available_Box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
loadconf;
set(hObject,'String',als_available);



% --- Executes on button press in doOneStep_Check.
function doOneStep_Check_Callback(hObject, eventdata, handles)
% hObject    handle to doOneStep_Check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of doOneStep_Check
hideMessage();
loadconf;
doOneStep = get(hObject,'Value');
saveconf;


% --- Executes during object creation, after setting all properties.
function doOneStep_Check_CreateFcn(hObject, eventdata, handles)
% hObject    handle to doOneStep_Check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
loadconf;
set(hObject,'Value',doOneStep);


% --- Executes on button press in doIterative_Check.
function doIterative_Check_Callback(hObject, eventdata, handles)
% hObject    handle to doIterative_Check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of doIterative_Check
hideMessage();
loadconf;
doIterative = get(hObject,'Value');
saveconf;


% --- Executes during object creation, after setting all properties.
function doIterative_Check_CreateFcn(hObject, eventdata, handles)
% hObject    handle to doIterative_Check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
loadconf;
set(hObject,'Value',doIterative);

% --- Executes on button press in doIterativeIID_Check.
function doIterativeIID_Check_Callback(hObject, eventdata, handles)
% hObject    handle to doIterativeIID_Check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of doIterativeIID_Check
loadconf;
hideMessage();
doIterativeIID = get(hObject,'Value');
saveconf;


% --- Executes during object creation, after setting all properties.
function doIterativeIID_Check_CreateFcn(hObject, eventdata, handles)
% hObject    handle to doIterativeIID_Check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
loadconf;
set(hObject,'Value',doIterativeIID);


function hideAll(tags)
for i=1:length(tags)
   set(findobj('Tag',tags{i}),'Visible','off');
end

function showAll(tags)
for i=1:length(tags)
   set(findobj('Tag',tags{i}),'Visible','on');
end

function hideALInfo()
tags = {'classifier_Text','classifier_Menu','field1_Text','field1_Edit',...
    'field2_Text','field2_Edit','field3_Text','field3_Edit','field4_Text','field4_Edit',...
    'field5_Text','field5_Edit','field6_Text','field6_Edit','alSaveOne_Button'...
    'alSaveAll_Button','alSaveAllNotset_Button'};
set(findobj('Tag','ALO'),'Title','ActiveLearner Options');
hideAll(tags);

function showALInfo()
tags = {'classifier_Text','classifier_Menu','field1_Text','field1_Edit',...
    'field2_Text','field2_Edit','field3_Text','field3_Edit','field4_Text','field4_Edit',...
    'field5_Text','field5_Edit','field6_Text','field6_Edit','alSaveOne_Button'...
    'alSaveAll_Button','alSaveAllNotset_Button'};
showAll(tags);

function hideDSInfo()
tags = {'whatYouCanSee_Text','whatYouCanSee_Edit',...
    'absolute_whatYouCanSee_Check','budgetPerStep_Text','budgetPerStep_Edit',...
    'absolute_budgetPerStep_Check','budgetReportingFrequency_Text','budgetReportingFrequency_Edit',...
    'absolute_budgetReportingFrequency_Check','totalBudget_Text','totalBudget_Edit','absolute_totalBudget_Check',...
    'strategy_Text','strategy_Edit','repFactor_Text','repFactor_Edit',...
    'dsSaveOne_Button','dsSaveAll_Button','dsSaveAllNotset_Button'};
set(findobj('Tag','DSO'),'Title','Dataset Options');
hideAll(tags);


function showDSInfo()
tags = {'whatYouCanSee_Text','whatYouCanSee_Edit',...
    'absolute_whatYouCanSee_Check','budgetPerStep_Text','budgetPerStep_Edit',...
    'absolute_budgetPerStep_Check','budgetReportingFrequency_Text','budgetReportingFrequency_Edit',...
    'absolute_budgetReportingFrequency_Check','totalBudget_Text','totalBudget_Edit','absolute_totalBudget_Check',...
    'strategy_Text','strategy_Edit','repFactor_Text','repFactor_Edit',...
    'dsSaveOne_Button','dsSaveAll_Button','dsSaveAllNotset_Button'};
showAll(tags);

function hideMessage()
set(findobj('Tag','alMessage_Text'),'Visible','off');
set(findobj('Tag','dsMessage_Text'),'Visible','off');
vis = get(findobj('Tag','Info_Text'),'Visible');
col = get(findobj('Tag','Info_Text'),'ForegroundColor');
if strcmp(vis,'on')
    if isequal(col,[1 0 0])
       set(findobj('Tag','Info_Text'),'Visible','off');
    end
end

function hideAllMessage()
set(findobj('Tag','alMessage_Text'),'Visible','off');
set(findobj('Tag','dsMessage_Text'),'Visible','off');
vis = get(findobj('Tag','Info_Text'),'Visible');
col = get(findobj('Tag','Info_Text'),'ForegroundColor');
if strcmp(vis,'on')
    %if isequal(col,[1 0 0])
       set(findobj('Tag','Info_Text'),'Visible','off');
    %end
end



function setDSInfo(name)
loadconf;
ds_info = ds_info_map.(name);

set(findobj('Tag','whatYouCanSee_Edit'),'String',num2str(ds_info.whatYouCanSee));
set(findobj('Tag','budgetPerStep_Edit'),'String',num2str(ds_info.budgetPerStep));
set(findobj('Tag','budgetReportingFrequency_Edit'),'String',num2str(ds_info.budgetReportingFrequency));
set(findobj('Tag','totalBudget_Edit'),'String',num2str(ds_info.totalBudget));

set(findobj('Tag','strategy_Edit'),'String',num2str(ds_info.strategy));
set(findobj('Tag','repFactor_Edit'),'String',num2str(ds_info.repFactor));

set(findobj('Tag','absolute_whatYouCanSee_Check'),'Value',ds_info.absolute_whatYouCanSee);
set(findobj('Tag','absolute_budgetPerStep_Check'),'Value',ds_info.absolute_budgetPerStep);
set(findobj('Tag','absolute_budgetReportingFrequency_Check'),'Value',ds_info.absolute_budgetReportingFrequency);
set(findobj('Tag','absolute_totalBudget_Check'),'Value',ds_info.absolute_totalBudget);

set(findobj('Tag','dsSaveOne_Button'),'String',['Save for: ' name]);

function setALInfo(name)
loadconf;
al_info = al_info_map.(name);
classifier_set = get(findobj('Tag','classifier_Menu'),'String');
index = 0;
if isempty(al_info.classifier)
    index = 1;
else
    index = find(strcmp(classifier_set,al_info.classifier));
end

if index == []
   index = 1;
   al_info_map.(name).classifier = '';
   saveconf;
end

set(findobj('Tag','classifier_Menu'),'Value',index);
fieldname_set = fieldnames(al_info);
for i=2:length(fieldname_set)
    field_name = fieldname_set{i};
    field_value = al_info.(field_name);
    set(findobj('Tag',['field' num2str(i-1) '_Text']),'String',[field_name ':']);
    set(findobj('Tag',['field' num2str(i-1) '_Edit']),'String',field_value);
end

for i=length(fieldname_set):6
	set(findobj('Tag',['field' num2str(i) '_Text']),'Visible','off');
    set(findobj('Tag',['field' num2str(i) '_Edit']),'Visible','off');
end

set(findobj('Tag','alSaveOne_Button'),'String',['Save for: ' name]);

function setDSMessage(name)

loadconf;
datasetConfig = ds_conf_map.(name);

ds_info_text = '';

if exist([name '.desc'],'file')
    ds_info_text = fileread([name '.desc']);
else
    ds_info_text = [ name '.desc does not exist!'];
end

ds_info_text = [ds_info_text char(10) char(10) 'primaryKeyCol: ' num2str(datasetConfig.primaryKeyCol)];
ds_info_text = [ds_info_text char(10)  'classCol: ' num2str(datasetConfig.classCol)];
ds_info_text = [ds_info_text char(10)  'crowdUserCols: ' array2string(datasetConfig.crowdUserCols)];
ds_info_text = [ds_info_text char(10)  'crowdLabelCols: ' array2string(datasetConfig.crowdLabelCols)];
if datasetConfig.fakeCrowd
        ds_info_text = [ds_info_text char(10)  'fakeCrowd: true'];
else
        ds_info_text = [ds_info_text char(10)  'fakeCrowd: false'];
end
if datasetConfig.balancedLabels
        ds_info_text = [ds_info_text char(10)  'balancedLabels: true'];
else
        ds_info_text = [ds_info_text char(10)  'balancedLabels: false'];
end
ds_info_text = [ds_info_text char(10)  'initialTrainRatio: ' num2str(datasetConfig.initialTrainRatio)];

if isfield(datasetConfig, 'learner')
    if strcmp(class(datasetConfig.learner),'function_handle')
        f = functions(datasetConfig.learner);
        ds_info_text = [ds_info_text char(10)  'learner: @' f.function];
    else
        ds_info_text = [ds_info_text char(10)  'learner: ' class(datasetConfig.learner)];
    end
else
        ds_info_text = [ds_info_text char(10)  'learner: Not Set'];    
end
ds_info_text = [ds_info_text char(10)  'featureCols: ' array2string(datasetConfig.featureCols)];
set(findobj('Tag','Info_Text'),'Visible','on','ForegroundColor','black','String',ds_info_text);
set(findobj('Tag','Info_Panel'),'Title',[name ' Information']);


function setALMessage(name)
loadconf;
try
    al = getALInstance(name,al_Full_map,al_info_map);
    
    al_info_text=evalc('disp_struct(al)');
catch
    al_info_text = 'error occors in getting active learner properties.';
end


set(findobj('Tag','Info_Text'),'Visible','on','ForegroundColor','black','String',al_info_text);
set(findobj('Tag','Info_Panel'),'Title',[name ' Information']);



% --- Executes during object creation, after setting all properties.
function ALO_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ALO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function DSO_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DSO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function Run_Edit_Callback(hObject, eventdata, handles)
% hObject    handle to Run_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Run_Edit as text
%        str2double(get(hObject,'String')) returns contents of Run_Edit as a double
hideMessage();
global cur_conf;
set(hObject,'String',['run_conf(''' cur_conf ''')']);

% --- Executes during object creation, after setting all properties.
function Run_Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Run_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global cur_conf;
set(findobj('Tag','Run_Edit'),'String',['run_conf(''' cur_conf ''')']);


% --- Executes on button press in Back_Button.
function Back_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Back_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close('crowd_GUI');
start_GUI;


% --- Executes on selection change in Change_Menu.
function Change_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Change_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Change_Menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Change_Menu
global cur_conf;
conf_set = get(findobj('Tag','Change_Menu'),'String');
index = get(findobj('Tag','Change_Menu'),'Value');
value = conf_set{index};
cur_conf = value;
close('crowd_GUI');
crowd_GUI;

% --- Executes during object creation, after setting all properties.
function Change_Menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Change_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

s = getConfigFiles();
if isempty(s)
    set(hObject,'String',['No Configuration Files']);
end
set(hObject,'String',s);
global cur_conf;
conf_set = get(findobj('Tag','Change_Menu'),'String');
index = find(strcmp(conf_set,cur_conf));
if index ==0
    index = 1;
end
set(findobj('Tag','Change_Menu'),'Value',index);


% --- Executes on button press in absolute_whatYouCanSee_Check.
function absolute_whatYouCanSee_Check_Callback(hObject, eventdata, handles)
% hObject    handle to absolute_whatYouCanSee_Check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of absolute_whatYouCanSee_Check
hideMessage();
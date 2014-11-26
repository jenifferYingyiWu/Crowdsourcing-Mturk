function varargout = rls2tools(varargin)

%  RLS2TOOLS
%
%   Graphic user interface(GUI) for regularized least squares with two 
%   layers (RLS2) and linear regularized least squares with two layers 
%   (RLS2LIN).
%
%   -----------------------------------------------------------------------
%   Copyright © 2010 Francesco Dinuzzo
% 
%   This program is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
% 
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
% 
%   You should have received a copy of the GNU General Public License
%   along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%   Please report comments, suggestions and bugs to:
%   francesco.dinuzzo@gmail.com
%

%% Initialization code
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @rls2tools_OpeningFcn, ...
    'gui_OutputFcn',  @rls2tools_OutputFcn, ...
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
%% GUI Opening, Create and Close functions

% --- Executes just before rls2tools is made visible.
function rls2tools_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
cleargui(handles);
% Update handles structure
guidata(hObject, handles);

function varargout = rls2tools_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

% --- Executes during object creation, after setting all properties.
function min_lambda_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function max_lambda_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function num_lambda_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function split_number_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function training_percentage_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function performancepopup_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function max_iterations_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit31_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit32_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function biasmenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function preprocessmenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% GUI Control Logic

%% Update status bar
function updateStatusBar(handles,string)
set(handles.status_string,'String',string);
drawnow;

%% Set state 0 (cleared)
function cleargui(handles)
s = mfilename('fullpath');
pathname = [fileparts(s) '\kernels'];
filename = 'default';
setKernel(filename, pathname);
set(handles.info_kernel_handle,'String',sprintf('Kernel function: %s', filename));

 
h = [handles.split_number ...
    handles.training_percentage ...
    handles.train_button ...
    handles.no_split ...
    handles.random_splits ...
    handles.cross_validation ...
    handles.insample_hold_out ...
    handles.validation_set ...
    handles.export_figures ...
    handles.RLS2LIN ...
    handles.RLS2 ...
    handles.plot_button ...
    handles.PDF_button...
    handles.verbose ...
    handles.plot_time ...
    handles.plot_iterations ...
    handles.plot_num_kernels ...
    handles.plot_training ...
    handles.plot_evaluation ...
    handles.plot_bestlambda ...
    handles.load_kernel ...
    handles.transductive ...
    handles.info_kernel_handle ...
    handles.training ...
    handles.plot_df ...
    handles.biasmenu ...
    handles.preprocessmenu ...
    handles.preprocessbutton];
set(h,'Enable','off');
set(handles.split_panel,'SelectionChangeFcn',@split_panel_SelectionChangeFcn);
set(handles.performance_panel,'SelectionChangeFcn',@performance_panel_SelectionChangeFcn);
set(handles.algorithm_panel,'SelectionChangeFcn',@algorithm_panel_SelectionChangeFcn);

%% Set state 1 (busy)
function setbusy(handles)
h = [handles.train_button ...
    handles.no_split ...
    handles.insample_hold_out ...
    handles.validation_set ...
    handles.random_splits ...
    handles.cross_validation ...
    handles.performancepopup ...
    handles.min_lambda ...
    handles.max_lambda ...
    handles.num_lambda ...
    handles.split_number ...
    handles.training_percentage ...
    handles.max_iterations ...
    handles.export_figures ...
    handles.RLS2LIN ...
    handles.RLS2 ...
    handles.plot_button ...
    handles.PDF_button...
    handles.verbose ...
    handles.plot_time ...
    handles.plot_iterations ...
    handles.plot_num_kernels ...
    handles.plot_training ...
    handles.plot_evaluation ...
    handles.plot_bestlambda ...
    handles.load_kernel ...
    handles.transductive ...
    handles.info_kernel_handle ...
    handles.training ...
    handles.plot_df ...
    handles.biasmenu ...
    handles.preprocessmenu ...
    handles.preprocessbutton];
set(h,'Enable','off');

%% Set state 2 (trainable)
function settrainable(handles)
h = [handles.train_button ...
    handles.no_split ...
    handles.random_splits ...
    handles.cross_validation ...
    handles.performancepopup ...
    handles.min_lambda ...
    handles.max_lambda ...
    handles.num_lambda ...
    handles.max_iterations ...
    handles.insample_hold_out ...
    handles.RLS2LIN ...
    handles.RLS2 ...
    handles.verbose ...
    handles.training ...
    handles.biasmenu ...
    handles.preprocessmenu ...
    handles.preprocessbutton];
set(h,'Enable','on');
split = get(get(handles.split_panel,'SelectedObject'),'tag');
switch  split
    case 'no_split'
        set(handles.split_number,'Enable','off');
        set(handles.training_percentage,'Enable','off');
        set(handles.insample_hold_out,'Enable','off');
        if(getVar('ellv'))
            set(handles.performance_panel,'SelectedObject',handles.validation_set);
        else
            set(handles.performance_panel,'SelectedObject',handles.training);
        end
    case 'cross_validation'
        set(handles.split_number,'Enable','on');
        set(handles.training_percentage,'Enable','off');
        set(handles.insample_hold_out,'Enable','on');
        set(handles.performance_panel,'SelectedObject',handles.insample_hold_out);
    case 'random_splits'
        set(handles.split_number,'Enable','on');
        set(handles.training_percentage,'Enable','on');
        set(handles.insample_hold_out,'Enable','on');
        set(handles.performance_panel,'SelectedObject',handles.insample_hold_out);
end

switch get(get(handles.algorithm_panel,'SelectedObject'),'tag');
    case 'RLS2'
        set(handles.info_kernel_handle,'Enable','on');
        set(handles.load_kernel,'Enable','on');
    case 'RLS2LIN'
        set(handles.info_kernel_handle,'Enable','off');
        set(handles.load_kernel,'Enable','off');
end

if(getVar('ellv'))
    set(handles.transductive,'Enable','on');
    set(handles.validation_set,'Enable','on');
end
read_settings(handles);

%% Set state 3 (plottable)
function setplottable(handles)
settrainable(handles);
h =[handles.plot_button ...
    handles.PDF_button...
    handles.export_figures ...
    handles.plot_time ...
    handles.plot_iterations ...
    handles.plot_num_kernels ...
    handles.plot_training ...
    handles.plot_evaluation ...
    handles.plot_bestlambda ...
    handles.plot_df];
set(h,'Enable','on');

%% Algorithm panel selection change function
function  algorithm_panel_SelectionChangeFcn(hObject,eventdata)
handles = guidata(hObject);
settrainable(handles);

%% Split panel selection change function
function split_panel_SelectionChangeFcn(hObject,eventdata)
handles = guidata(hObject);
settrainable(handles);

%% Performance panel selection change function
function performance_panel_SelectionChangeFcn(hObject,eventdata)
handles = guidata(hObject);
read_settings(handles);

%% Set variable in workspace settings structure
function setVar(name,value)
s = sprintf('settings.%s = %s;',name,name);
assignin('base',name,value);
evalin('base',s);
evalin('base',['clear ' name]);

%% Get variable from workspace settings structure
function value = getVar(name)
value = evalin('base',['settings.' name ';']);

%% Read settings and check validity
function valid = read_settings(handles)
valid = 1;

verbose = get(handles.verbose,'Value');
split = get(get(handles.split_panel,'SelectedObject'),'Tag');
performance_settings = get(get(handles.performance_panel,'SelectedObject'),'Tag');
algorithm = get(get(handles.algorithm_panel,'SelectedObject'),'Tag');
ell = getVar('ell');

setVar('verbose',verbose);
setVar('split',split);
setVar('performance_settings',performance_settings);
setVar('algorithm',algorithm);

if (strcmp(split,'random_splits') || strcmp(split,'cross_validation'))
    numsplits = str2double(get(handles.split_number,'String'));
    if (isnan(numsplits))
        valid = 0;
        updateStatusBar(handles, sprintf('The number k must be an integer between 1 and %g', ell));
    elseif(numsplits < 1 || ne(mod(numsplits,1),0) || (numsplits > ell && strcmp(split,'cross_validation')))
        valid = 0;
        updateStatusBar(handles, sprintf('The number k must be an integer between 1 and %g', ell));
    else
        setVar('numsplits',numsplits);
    end
    if (strcmp(split,'random_splits'))
        percentage = str2double(get(handles.training_percentage,'String'));
        if (isnan(percentage))
            valid = 0;
            updateStatusBar(handles,'Training set % must be a number between 1 and 100');
        elseif(percentage > 100 || percentage < 0)
            valid = 0;
            updateStatusBar(handles,'Training set % must be a number between 1 and 100');
        else
            percentage = percentage/100;
            setVar('percentage',percentage);
        end
    end
else
    setVar('numsplits',1);
    setVar('percentage',1);
end
max_iterations = str2double(get(handles.max_iterations,'String'));
if (isnan(max_iterations))
    valid = 0;
    updateStatusBar(handles, 'Maximum number of iterations must be an integer greater that 1');
elseif(max_iterations < 2 || ne(mod(max_iterations,1),0))
    valid = 0;
    updateStatusBar(handles, 'Maximum number of iterations must be an integer greater that 1');
else
    setVar('max_iterations',max_iterations);
end
performance_type = get(handles.performancepopup,'Value');
performance_name =  get(handles.performancepopup,'String');
performance_name = char(performance_name(performance_type));

setVar('performance_type',performance_type);
setVar('performance_name',performance_name);

%% Callbacks
function split_number_Callback(hObject, eventdata, handles)
read_settings(handles);

function training_percentage_Callback(hObject, eventdata, handles)
read_settings(handles);

function max_iterations_Callback(hObject, eventdata, handles)
read_settings(handles);

function performancepopup_Callback(hObject, eventdata, handles)
read_settings(handles);

function verbose_Callback(hObject, eventdata, handles)
read_settings(handles);

function plot_button_Callback(hObject, eventdata, handles)
plot_statistics(handles,0);

function export_figures_Callback(hObject, eventdata, handles)
plot_statistics(handles,1);

function PDF_button_Callback(hObject, eventdata, handles)
plot_statistics(handles,1);

function max_lambda_Callback(hObject, eventdata, handles)

function min_lambda_Callback(hObject, eventdata, handles)

function num_lambda_Callback(hObject, eventdata, handles)

function file_menu_Callback(hObject, eventdata, handles)

function plot_time_Callback(hObject, eventdata, handles)

function plot_iterations_Callback(hObject, eventdata, handles)

function plot_num_kernels_Callback(hObject, eventdata, handles)

function plot_training_Callback(hObject, eventdata, handles)

function plot_evaluation_Callback(hObject, eventdata, handles)

function plot_bestlambda_Callback(hObject, eventdata, handles)

function transductive_Callback(hObject, eventdata, handles)

function plot_df_Callback(hObject, eventdata, handles)

function biasmenu_Callback(hObject, eventdata, handles)

function preprocessmenu_Callback(hObject, eventdata, handles)


%% Load data
function load_data_Callback(hObject, eventdata, handles)

[filename, pathname] = uigetfile('*.mat', 'MAT file');
assignin('base','filename',filename);
assignin('base','pathname',pathname);
if (~isequal(filename,0) && ~isequal(pathname,0))
    if (evalin('base','(isempty(strmatch(''X'',who(''-file'',[pathname filename]),''exact'')) || isempty(strmatch(''Y'',who(''-file'',[pathname filename]),''exact'')));' ))
        updateStatusBar(handles,'Invalid training file format.');
    else
        setbusy(handles);
        evalin('base','clear K Kv Xv Yv statistics models;');
        s = sprintf('Status: loading %s ...', filename);
        updateStatusBar(handles,s);
        cleargui(handles);
        evalin('base','load([pathname filename],''X'',''Y'');');

        %Output pre-processing
        if(evalin('base','isa(Y,''nominal'')'))
            %Classification
            Y = evalin('base','Y');
            classes = unique(Y);
            m = length(classes);
            if m > 2
                L = sparse(length(Y),m);
                for k=1:m
                    L(eq(classes(k),Y),k) = 1;
                end
                assignin('base','Y',L);
                set(handles.data_info5,'String','Problem type: multi-class classification');
            else
                L = zeros(size(Y));
                L(eq(classes(1),Y)) = 1;
                L(eq(classes(2),Y)) = -1;
                assignin('base','Y',L);
                set(handles.data_info5,'String','Problem type: binary classification');
            end
            
            evalin('base','settings.problem_type = ''classification'';');
            set(handles.performancepopup,'String',{'Accuracy'  'Balanced Accuracy'});
            set(handles.biasmenu,'Value',1);
        else
            %Regression
            if evalin('base','size(Y,2)') > 1
                set(handles.data_info5,'String','Problem type: multi-output regression');
            else
                set(handles.data_info5,'String','Problem type: regression');
            end
            evalin('base','settings.problem_type = ''regression'';');
            set(handles.performancepopup,'String',{'RMSE' 'MSE' 'MAE'});
            set(handles.biasmenu,'Value',2);
        end

        if (evalin('base','~isempty(strmatch(''T'',who(''-file'',[pathname filename]),''exact''))'))
            evalin('base','load([pathname filename],''T'');');
            evalin('base','Xv = X(T,:);')
            evalin('base','Yv = Y(T,:);')
            evalin('base','X =  X(~T,:);')
            evalin('base','Y =  Y(~T,:);')
            ellv  = evalin('base','size(Xv,1);');
            setVar('ellv',ellv);
            set(handles.performance_panel,'SelectedObject',handles.validation_set);
            set(handles.split_panel,'SelectedObject',handles.no_split);
        else
            ellv = 0;
            setVar('ellv',ellv);
        end
        [ell n] = evalin('base','size(X);');
        [ell m] = evalin('base','size(Y);');
        
        setVar('ell',ell);
        setVar('n',n);
        setVar('m',m);

        s = sprintf('Data file: %s', filename);
        set(handles.data_info1,'String',s);
        s = sprintf('Training examples: %d', ell);
        set(handles.data_info2,'String',s);
        s = sprintf('Number of features: %d', n);
        set(handles.data_info3,'String',s);
        s = sprintf('Validation/Test examples: %d', ellv);
        set(handles.data_info4,'String',s);
        s = sprintf('Number of outputs: %d', m);
        set(handles.data_info6,'String',s);
       
        updateStatusBar(handles,'Status: ready.');
        settrainable(handles);
    end
end
evalin('base','clear pathname filename');

%% Load customized kernel function
function load_kernel_Callback(hObject, eventdata, handles)
curdir = cd;
s = mfilename('fullpath');
pathname = [fileparts(s) '\kernels'];
cd(pathname); 

[filename, pathname] = uigetfile('*.m', 'M file');
if (~isequal(filename,0) && ~isequal(pathname,0))
setKernel(filename, pathname);
set(handles.info_kernel_handle,'String',sprintf('Kernel function: %s', filename));
end
cd(curdir);

%% Set kernel function
function setKernel(filename, pathname)
setVar('kernel_path',pathname);
setVar('kernel_function',strtok(filename,'.'));

%% Pre-process
function preprocessbutton_Callback(hObject, eventdata, handles)
setbusy(handles)
updateStatusBar(handles,'Status: pre-processing...');

switch(get(handles.preprocessmenu,'Value'))
    %Subtract feature's mean
    case 1
        if(get(handles.transductive,'Value'))
            evalin('base','M = (sum(X)+sum(Xv))/(settings.ell+settings.ellv);');
        else
            evalin('base','M = mean(X);');
        end
        if(get(handles.transductive,'Value'))
            for i=1:getVar('n')
                assignin('base','i',i);
                evalin('base','X(:,i) = X(:,i)-M(i);');
                evalin('base','Xv(:,i) = Xv(:,i)-M(i);');
            end
        else
            for i=1:getVar('n')
                assignin('base','i',i);
                evalin('base','X(:,i) = X(:,i)-M(i);');
            end
        end
        evalin('base','clear M i');

    %Standardize features
    case 2
        if(get(handles.transductive,'Value'))
            evalin('base','M = (sum(X)+sum(Xv))/(settings.ell+settings.ellv);');
        else
            evalin('base','M = mean(X);');
        end
        if(get(handles.transductive,'Value'))
            for i=1:getVar('n')
                assignin('base','i',i);
                evalin('base','Si = std([X(:,i); Xv(:,i)]);');
                evalin('base','if (Si), X(:,i) = (X(:,i)-M(i))/Si; else X(:,i) = 0; end');
                evalin('base','if (Si), Xv(:,i) = (Xv(:,i)-M(i))/Si; else Xv(:,i) = 0; end');
            end
        else
            for i=1:getVar('n')
                assignin('base','i',i);
                evalin('base','Si = std(X(:,i));');
                evalin('base','if (Si), X(:,i) = (X(:,i)-M(i))/Si; else X(:,i) = 0; end');
            end
        end
        evalin('base','clear M Si i');
        
    %Length one features
    case 3
        if(get(handles.transductive,'Value'))
            for i=1:getVar('n')
                assignin('base','i',i);
                evalin('base','Si = norm([X(:,i); Xv(:,i)]);');
                evalin('base','if (Si), X(:,i) = X(:,i)/Si; Xv(:,i) = Xv(:,i)/Si; else X(:,i) = 0; Xv(:,i) = 0; end');
            end
        else
            for i=1:getVar('n')
                assignin('base','i',i);
                evalin('base','Si = norm(X(:,i));');
                evalin('base','if (Si), X(:,i) = X(:,i)/Si; else X(:,i) = 0; end');
            end
        end
        evalin('base','clear M Si i');
        
    %Subtract example's mean
    case 4
        evalin('base','M = mean(X,2);');
        for i=1:getVar('ell')
            assignin('base','i',i);
            evalin('base','X(i,:) = X(i,:)-M(i);');
        end
        if getVar('ellv')
            evalin('base','M = mean(Xv,2);');
            for i=1:getVar('ellv')
                assignin('base','i',i);
                evalin('base','Xv(i,:) = Xv(i,:)-M(i);');
            end
        end
        evalin('base','clear M i');
        
    %Standardize examples
    case 5
        evalin('base','M = mean(X,2);');
        for i=1:getVar('ell')
            assignin('base','i',i);
            evalin('base','Si = std(X(i,:));');
            evalin('base','if (Si), X(i,:) = (X(i,:)-M(i))/Si; else X(i,:) = 0; end');
        end
        if getVar('ellv')
            evalin('base','M = mean(Xv,2);');
            for i=1:getVar('ellv')
                assignin('base','i',i);
                evalin('base','Si = std(Xv(i,:));');
                evalin('base','if (Si), Xv(i,:) = (Xv(i,:)-M(i))/Si; else Xv(i,:) = 0; end');
            end
        end
        evalin('base','clear M Si i');

    %Length one examples
    case 6
        for i=1:getVar('ell')
            assignin('base','i',i);
            evalin('base','Si = norm(X(i,:));');
            evalin('base','if (Si), X(i,:) = X(i,:)/Si; else X(i,:) = 0; end');
        end
        if getVar('ellv')
            for i=1:getVar('ellv')
                assignin('base','i',i);
                evalin('base','Si = norm(Xv(i,:));');
                evalin('base','if (Si), Xv(i,:) = Xv(i,:)/Si; else X(i,:) = 0; end');
            end
        end
        evalin('base','clear M Si i');
        
    %Randomize examples
    case 7
        assignin('base','I',randperm(getVar('ell')));
        evalin('base','X = X(I,:);');
        evalin('base','Y = Y(I,:);');
        evalin('base','clear I;');
end

updateStatusBar(handles,'Status: ready.');
settrainable(handles);

%% Extract set of kernel sub-matrices
function KIJ = kernelstackat(K,I,J)
m = length(K);
KIJ = cell(m,1);
for i=1:m
    A = cell2mat(K(i));
    KIJ(i) = {A(I,J)};
end

%% Compute scaling
function S = compute_scaling
switch(getVar('algorithm'))
    case 'RLS2'
        n = evalin('base','length(K)');
        m = getVar('m');
        S = zeros(n,m);
        for i=1:n
            assignin('base','i',i);
            S(i,:) = evalin('base','repmat(1/trace(cell2mat(K(i))),settings.m,1);');
        end
        evalin('base','clear i');
    case'RLS2LIN'
        S = evalin('base','1./repmat(sum(X.^2,1)+sqrt(eps),settings.m,1)'';');
end

%% Training
% --- Executes on button press in train_button.
function train_button_Callback(hObject, eventdata, handles)
% hObject    handle to train_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

valid = read_settings(handles);
lambdamin = str2double(get(handles.min_lambda,'String'));
lambdamax = str2double(get(handles.max_lambda,'String'));
num = str2double(get(handles.num_lambda,'String'));
if (isnan(lambdamin) || isnan(lambdamax))
    valid = 0;
    updateStatusBar(handles,'Lambda must be a positive number');
elseif(lambdamin <= 0 || lambdamax <= 0)
    valid = 0;
    updateStatusBar(handles,'Lambda must be a positive number');
elseif(lambdamin >= lambdamax)
    valid = 0;
    updateStatusBar(handles,'Minimum lambda must be less than maximum lambda');
elseif(isinf(lambdamax))
    valid = 0;
    updateStatusBar(handles,'Maximum lambda must be finite');
end
if (isnan(num))
    valid = 0;
    updateStatusBar(handles, 'N must be an integer greater or equal 2');
elseif(num < 2 || ne(mod(num,1),0))
    valid = 0;
    updateStatusBar(handles, 'N must be an integer greater or equal 2');
end

if (valid)
    evalin('base','clear models;');
    lambda = logspace(log10(lambdamin),log10(lambdamax),num);
    setVar('lambda',lambda);

    split = getVar('split');
    algorithm = getVar('algorithm');
    ell = getVar('ell');

    setbusy(handles);
    if (strmatch(algorithm,'RLS2'))
        updateStatusBar(handles,'Status: building kernels...');
        curdir = cd;
        cd(getVar('kernel_path'));
        evalin('base',['K =', getVar('kernel_function'),'(X,X);']);
        cd(curdir);
    end
    setVar('S',compute_scaling);

    updateStatusBar(handles,'Status: training...');
    numsplits = getVar('numsplits');
    validationsize = max(1,round(ell/numsplits));

    for i=1:numsplits
        assignin('base','i',i);
        switch split
            case 'no_split'
                evalin('base','I = 1:settings.ell'';');
            case 'random_splits'
                percentage = evalin('base','settings.percentage;');
                trainsize = min(ell-1,max(1,round(percentage*ell)));
                I = randperm(ell)';
                I = sort(I(1:trainsize));
                assignin('base','I', I);
                assignin('base','Ic', setdiff(1:ell,I)');
            case 'cross_validation'
                assignin('base','Ic',(1+validationsize*(i-1)):min(ell,i*validationsize));
                evalin('base','I = setdiff(1:settings.ell,Ic)'';');
        end
        msg = sprintf('Split n. %d',i);
        disp(msg);
        
        evalin('base','param = struct(''d0'',[],''S'',settings.S,''maxIT'',settings.max_iterations,''verbose'',settings.verbose);');
        switch get(handles.biasmenu,'Value')
            case 1
                 evalin('base','param.b = [];');
            case 2
                evalin('base','param.b = mean(Y);');
        end
        
        %Regularization path
        for k=1:num
            j = num+1-k;
            assignin('base','j',j);
            if (strcmp(split,'random_splits') || strcmp(split,'cross_validation'))
                updateStatusBar(handles,sprintf('Status: (using %g training / %g validation). Training (split %g / %g, regularization path %g / %g)...',evalin('base','length(I);'), evalin('base','length(Ic)'), i,numsplits,k,num));
            else
                updateStatusBar(handles,sprintf('Status:  training (regularization path %g / %g)...', k,num));
            end
            %Training
            evalin('base','tic');
            
            switch (algorithm)
                case 'RLS2LIN'
                    evalin('base','model = rls2lin(X(I,:),Y(I,:),settings.lambda(j),param);');
                case 'RLS2'
                    evalin('base','model = rls2(kernelstackat(K,I,I),Y(I,:),settings.lambda(j),param);');
            end
            evalin('base','param.d0 = model.d;');
            evalin('base','model.lambda = settings.lambda(j);');
            evalin('base','model.training_index = I;');
            evalin('base','model.training_time = toc;');
            assignin('base','algorithm',algorithm);
            evalin('base','model.algorithm = algorithm;');
            evalin('base','clear algorithm;');
            
            evalin('base','models(i,j) = model;');
        end
    end
    evalin('base','clear model param i k I Ic A time;');
    evalin('base','settings.models_split =settings.split;')
    setplottable(handles);
    updateStatusBar(handles,'Status: ready.');
end

%% Evaluate performances

function L = performance(Y,training_predictions,problem_type,performance_type)
if (~isempty(Y) && ~isempty(training_predictions))
    switch(problem_type)
        case 'classification'  
            [ell,m] = size(Y);
            if m > 1
                %One versus all classification
                [mm Y] = max(Y,[],2);
                [mm training_predictions] = max(training_predictions,[],2);
            else
                training_predictions = sign(training_predictions);
            end
   
            classes = unique([Y ; training_predictions]); 
            m = length(classes);
            confusion = zeros(m,m);
            
            %Confusion matrix
            for i=1:m
                for j=1:m
                    confusion(i,j) = sum(eq(Y,classes(i)).*eq(training_predictions,classes(j)));
                end
            end
           
            switch(performance_type)
                case 1
                    L = trace(confusion)/sum(sum(confusion));       %Accuracy   
                case 2
                    u = diag(confusion);
                    v = sum(confusion,2);
                    I = ne(v,0);
                    L = mean(u(I)./v(I));    %Balanced Accuracy
            end
            
        case 'regression'
            switch(performance_type)
                case 1
                    L = sqrt(mean2((Y-training_predictions).^2));  %RMSE
                case 2
                    L = mean2((Y-training_predictions).^2);        %MSE
                case 3
                    L = mean2(abs(Y-training_predictions));        %MAE
            end
    end
else
    L = NaN;
end


%% Extract statistics from workspace models
function extract

performance_settings = getVar('performance_settings');
performance_type = getVar('performance_type');
problem_type = getVar('problem_type');

[numsplits numlambda] = evalin('base','size(models);');

lambda = zeros(1,numlambda);
training_performance = zeros(numsplits,numlambda);
evaluation_performance = zeros(numsplits,numlambda);
df = zeros(numsplits,numlambda);
num_kernels = zeros(numsplits,numlambda);
training_time = zeros(numsplits,numlambda);
iterations = zeros(numsplits,numlambda);

for j=1:numlambda
    assignin('base','j',j);
    lambda(1,j) = evalin('base','models(1,j).lambda;');
end

for i=1:numsplits
    assignin('base','i',i);
    evalin('base','I  = models(i,1).training_index;');
    evalin('base','Ic = setdiff(1:settings.ell,I);');
    algorithm = evalin('base','models(i,1).algorithm');
    
    if strmatch(algorithm,'RLS2')
        if (strmatch(performance_settings,'insample_hold_out'))
            evalin('base','Kv = kernelstackat(K,Ic,I);');
        end
        if (strmatch(performance_settings,'validation_set'))
            curdir = cd;
            cd(getVar('kernel_path'));
            evalin('base',['Kv =', getVar('kernel_function'),'(Xv,X(I,:));']);
            cd(curdir);
        end
    end

    for j=1:numlambda
        assignin('base','j',j);
        training_time(i,j) = evalin('base','models(i,j).training_time;');
        iterations(i,j) = evalin('base','sum(models(i,j).iterations);');
        num_kernels(i,j) = evalin('base','full(sum(ne(sum(models(i,j).d,2),0)));');
        df(i,j) = evalin('base','sum(models(i,j).df);');
        training_performance(i,j) = performance(evalin('base','Y(I,:)'),evalin('base','models(i,j).training_predictions'),problem_type,performance_type);
        switch (algorithm)
            case 'RLS2'
                switch(performance_settings)
                    case 'training' 
                        evaluation_performance(i,j) = training_performance(i,j);
                    case 'insample_hold_out'
                        evaluation_performance(i,j) = performance(evalin('base','Y(Ic,:)'),evalin('base','rls2eval(Kv,models(i,j));'),problem_type,performance_type);
                    case 'validation_set'
                        evaluation_performance(i,j) = performance(evalin('base','Yv'),evalin('base','rls2eval(kernelstackat(Kv,1:settings.ellv,I),models(i,j));'),problem_type,performance_type);
                end
            case 'RLS2LIN'
                switch(performance_settings)
                    case 'training'
                        evaluation_performance(i,j) = training_performance(i,j);
                    case 'insample_hold_out'
                        evaluation_performance(i,j) = performance(evalin('base','Y(Ic,:)'),evalin('base','rls2lineval(X(Ic,:),X(I,:),models(i,j));'),problem_type,performance_type);
                    case 'validation_set'
                        evaluation_performance(i,j) = performance(evalin('base','Yv'),evalin('base','rls2lineval(Xv,X(I,:),models(i,j));'),problem_type,performance_type);
                end
        end
    end
end

evalin('base','clear i j I Ic;');
assignin('base','lambda',lambda);
assignin('base','training_time',training_time);
assignin('base','iterations', iterations);
assignin('base','num_kernels',num_kernels);
assignin('base','training_performance',training_performance);
assignin('base','evaluation_performance',evaluation_performance);
assignin('base','df',df);
evalin('base','statistics = struct(''lambda'',lambda,''training_time'',training_time,''iterations'',iterations,''num_kernels'',num_kernels,''training_performance'',training_performance,''evaluation_performance'',evaluation_performance,''df'',df);');
                
evalin('base','clear lambda iterations num_kernels training_time training_performance evaluation_performance df');


%% Plot statistics
function plot_statistics(handles,pdf_flag)
valid = 1;
if (evalin('base','exist(''models'',''var'')'))
    if (pdf_flag)
        path = uigetdir;
        if (~isequal(path,0) && isdir(path))
            updateStatusBar(handles,'Status: generating PDF files...');
        else
            valid = 0;
        end
    else
        updateStatusBar(handles,'Status: plotting...');
    end
else
    valid = 0;
end
if (valid)
    results_type = getVar('models_split');
    performance_settings = getVar('performance_settings');
    problem_type = getVar('problem_type');

    numplots =  get(handles.plot_time,'Value') + ...
        get(handles.plot_iterations,'Value') + ...
        get(handles.plot_num_kernels,'Value') + ...
        get(handles.plot_training,'Value') + ...
        get(handles.plot_evaluation,'Value') + ...
        get(handles.plot_df,'Value');
    switch numplots
        case 1
            string = '11';
        case 2
            string = '12';
        case 3
            string = '13';
        case 4
            string = '22';
        case 5
            string = '23';
        case 6
            string = '23';
    end

    if (numplots >= 1)
        extract(); 
        lambda = evalin('base','statistics.lambda;');

        if (pdf_flag)
            fig = figure('Visible','off');
        else
            fig = figure('Visible','on');
        end
        
        evaluation_performance = evalin('base','statistics.evaluation_performance');

        bestlambda = get(handles.plot_bestlambda,'Value');
        if (bestlambda)
            if (~any(isnan(evaluation_performance)))
                M = mean(evaluation_performance,1);
                switch problem_type
                    case 'classification'
                        [mm iopt] = max(M);
                    case 'regression'
                        [mm iopt] = min(M);
                end
                lambdaopt = lambda(iopt);
            else
                lambdaopt = [];
            end
        else
            lambdaopt = [];
        end

        %Titles
        training_title = ['Training ' evalin('base','settings.performance_name;')];
        evaluation_title = ['Validation ' evalin('base','settings.performance_name;')];
        df_title = 'Degrees of freedom';
        kernel_title = 'Selected kernels ';
        iteration_title = 'Number of iterations ';
        training_time_title = 'Training time ';
        numsplits = evalin('base','size(models,1);');
        percentage = round(100*evalin('base','length(models(1,1).training_index)/length(Y);'));
        switch(results_type)
            case 'random_splits'
                training_title = [training_title sprintf(' (%g random splits %g/%g)',numsplits,percentage,100-percentage)];
                evaluation_title = [evaluation_title sprintf(' (%g random splits %g/%g)',numsplits,percentage,100-percentage)];
                df_title = [df_title sprintf(' (%g random splits %g/%g)',numsplits,percentage,100-percentage)];
                kernel_title = [kernel_title sprintf(' (%g random splits %g/%g)',numsplits,percentage,100-percentage)];
                iteration_title = [iteration_title sprintf(' (%g random splits %g/%g)',numsplits,percentage,100-percentage)];
                training_time_title = [training_time_title sprintf(' (%g random splits %g/%g)',numsplits,percentage,100-percentage)];
            case 'cross_validation'
                training_title = [training_title sprintf(' (%g-fold CV)',numsplits)];
                evaluation_title = [evaluation_title sprintf(' (%g-fold CV)',numsplits)];
                df_title = [df_title sprintf(' (%g-fold CV)',numsplits)];
                kernel_title = [kernel_title sprintf(' (%g-fold CV)',numsplits)];
                iteration_title = [iteration_title sprintf(' (%g-fold CV)',numsplits)];
                training_time_title = [training_time_title sprintf(' (%g-fold CV)',numsplits)];
        end
        switch(performance_settings)
            case 'validation_set'
                evaluation_title = [evaluation_title ' (validation set)'];
        end

        kk = 1;

        %%Training performances
        if (get(handles.plot_training,'Value'))
            if (pdf_flag)
                filename = [path '\training.pdf'];
                plot_training(training_title,lambda,lambdaopt);
                save2pdf(filename,fig,1000);
            else
                subplot(sprintf('%s%g',string,kk));
                kk = kk+1;
                plot_training(training_title,lambda,lambdaopt);
            end
        end

        %%Validation performances
        if (get(handles.plot_evaluation,'Value'))
            if (pdf_flag)
                filename = [path '\evaluation.pdf'];
                plot_evaluation(evaluation_title,lambda,lambdaopt);
                save2pdf(filename,fig,1000);
            else
                subplot(sprintf('%s%g',string,kk));
                kk = kk+1;
                plot_evaluation(evaluation_title,lambda,lambdaopt);
            end
        end
        
         %%Degrees of freedom
        if (get(handles.plot_df,'Value'))
            if (pdf_flag)
                filename = [path '\df.pdf'];
                plot_df(df_title,lambda,lambdaopt);
                save2pdf(filename,fig,1000);
            else
                subplot(sprintf('%s%g',string,kk));
                kk = kk+1;
                plot_df(df_title,lambda,lambdaopt);
            end
        end

        %%Number of kernels
        if (get(handles.plot_num_kernels,'Value'))
            if (pdf_flag)
                filename = [path '\num_kernels.pdf'];
                plot_num_kernels(kernel_title,lambda,lambdaopt);
                save2pdf(filename,fig,1000);
            else
                subplot(sprintf('%s%g',string,kk));
                kk = kk+1;
                plot_num_kernels(kernel_title,lambda,lambdaopt);
            end
        end


        %% Training time
        if (get(handles.plot_time,'Value'))
            if (pdf_flag)
                filename = [path '\training_time.pdf'];
                plot_time(training_time_title,lambda,lambdaopt);
                save2pdf(filename,fig,1000);
            else
                subplot(sprintf('%s%g',string,kk));
                kk = kk+1;
                plot_time(training_time_title,lambda,lambdaopt);
            end
        end

        %% Number of iterations
        if (get(handles.plot_iterations,'Value'))
            if (pdf_flag)
                filename = [path '\iterations.pdf'];
                plot_iterations(iteration_title,lambda,lambdaopt);
                save2pdf(filename,fig,1000);
            else
                subplot(sprintf('%s%g',string,kk));
                plot_iterations(iteration_title,lambda,lambdaopt);
            end
        end

        if (pdf_flag)
            close(fig);
        end
    end
end
updateStatusBar(handles,'Status: ready.');

%% Plot Training Performances
function plot_training(plottitle,lambda,lambdaopt)
training_performance = evalin('base','statistics.training_performance');
varplot(lambda,training_performance);
YL = ylim;
if(strmatch(getVar('problem_type'),'classification'))
    YL(2) = min(1,YL(2));
    ylim(YL);
end
if (~isempty(lambdaopt))
    plot(lambdaopt*ones(1,100),linspace(YL(1),YL(2),100),'r--','LineWidth',2);
end
title(plottitle,'FontWeight','bold');

%% Plot Validation Performances
function plot_evaluation(plottitle,lambda,lambdaopt)
evaluation_performance = evalin('base','statistics.evaluation_performance');
varplot(lambda,evaluation_performance);
YL = ylim;
if(strmatch(getVar('problem_type'),'classification'))
    YL(2) = min(1,YL(2));
    ylim(YL);
end
title(plottitle,'FontWeight','bold');
if (~isempty(lambdaopt))
    plot(lambdaopt*ones(1,100),linspace(YL(1),YL(2),100),'r--','LineWidth',2);
    str = sprintf('$\\lambda^*$=%0.2e',lambdaopt);
    XL = xlim;
    text(XL(1),YL(1)+0.9*(YL(2)-YL(1)),str,'Interpreter','latex');
end

%% Plot Degrees of freedom
function plot_df(plottitle,lambda,lambdaopt)
df = evalin('base','statistics.df');
varplot(lambda,df);
YL = ylim;
YL(1) = max(0,YL(1));
ylim(YL);
title(plottitle,'FontWeight','bold');
if (~isempty(lambdaopt))
    plot(lambdaopt*ones(1,100),linspace(YL(1),YL(2),100),'r--','LineWidth',2);
end

%% Plot Selected Kernels
function plot_num_kernels(plottitle,lambda,lambdaopt)
num_kernels = evalin('base','statistics.num_kernels');
varplot(lambda,num_kernels);
YL = ylim;
YL(1) = max(0,YL(1));
ylim(YL);
title(plottitle,'FontWeight','bold');
if (~isempty(lambdaopt))
    plot(lambdaopt*ones(1,100),linspace(YL(1),YL(2),100),'r--','LineWidth',2);
end

%% Plot Training Time
function plot_time(plottitle,lambda,lambdaopt)
training_time = evalin('base','statistics.training_time');
varplot(lambda,training_time);
YL = ylim;
YL(1) = max(0,YL(1));
ylim(YL);
title(plottitle,'FontWeight','bold');
if (~isempty(lambdaopt))
    plot(lambdaopt*ones(1,100),linspace(YL(1),YL(2),100),'r--','LineWidth',2);
end

%% Plot Number of Iterations
function plot_iterations(plottitle,lambda,lambdaopt)
iterations = evalin('base','statistics.iterations');
varplot(lambda,iterations);
YL = ylim;
YL(1) = max(0,YL(1));
ylim(YL);
title(plottitle,'FontWeight','bold');
if (~isempty(lambdaopt))
    plot(lambdaopt*ones(1,100),linspace(YL(1),YL(2),100),'r--','LineWidth',2);
end

%% Variability Plot
function  h = varplot(X,Y)
cla
hold off
h = semilogx(X,Y','Color',[0.8 0.8 1]);
axis square;
axis tight;
hold on;
semilogx(X,mean(Y,1),'LineWidth',2);
semilogx(X,mean(Y,1)+std(Y,0,1),'--');
semilogx(X,mean(Y,1)-std(Y,0,1),'--');
xlabel('$\lambda$','Interpreter','latex');

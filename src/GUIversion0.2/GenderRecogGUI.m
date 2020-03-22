% Name:     GenderRecogGUI 0.2
% Function: Recognition of speaker's gender based on his/her speech signal.
%           The COMPLETE version of GenderRecogGUI 0.1

% Copyright (c) 2019 CHEN Tianyang
% more info contact: tychen@whu.edu.cn

%%
function varargout = GenderRecogGUI(varargin)
% GENDERRECOGGUI MATLAB code for GenderRecogGUI.fig
%      GENDERRECOGGUI, by itself, creates a new GENDERRECOGGUI or raises the existing
%      singleton*.
%
%      H = GENDERRECOGGUI returns the handle to a new GENDERRECOGGUI or the handle to
%      the existing singleton*.
%
%      GENDERRECOGGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GENDERRECOGGUI.M with the given input arguments.
%
%      GENDERRECOGGUI('Property','Value',...) creates a new GENDERRECOGGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GenderRecogGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GenderRecogGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menusettings.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GenderRecogGUI

% Last Modified by GUIDE v2.5 02-Apr-2019 10:32:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GenderRecogGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @GenderRecogGUI_OutputFcn, ...
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


% --- Executes just before GenderRecogGUI is made visible.
function GenderRecogGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GenderRecogGUI (see VARARGIN)

% Choose default command line output for GenderRecogGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GenderRecogGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);
% һЩ��ʼ�����ݷ�������
% ��Ӻ���·��
addpath(genpath([pwd,'\myfunctions']));
addpath(genpath([pwd,'\libsvm322']));
global control;
control.classifier = 'NaiveBayes';        % ����������
control.fold_list = [];         % ���ݼ������ļ���
control.ftsstruct = [];         % ���ݼ������������ɵĽṹ��
control.traindata = [];         % ѵ��������
control.trainlabel = [];        % ѵ������ǩ
control.valdata = [];           % ��֤������
control.vallabel = [];          % ��֤����ǩ
control.ftsRange = 20;          % Ĭ��NB������������Χ��0-20����
control.clusters = 7;           % Ĭ��KMSKNN�ľ�������������7
control.Knearest = 1;           % Ĭ��KNN�����ڽ���Χ��1
control.ValCorrRate = [];       % ��֤��-׼ȷ��
control.RecallRate = [];        % ��֤��-�ٻ���
control.TrainSegRatio = 0.7;    % Ĭ��ѵ����/��֤��=7/3
control.datasetpath = [];       % ���ݼ���ַ[ones(1,13) zeros(1,26)]
control.featurechanged = zeros(1,8);       % �����Ƿ��Ѿ��ı� 0-û�иı� 1-�Ѿ��ı�
control.CurrentSplitRatioChoice = 3;               % Ĭ��ѡ7/3�ķָ����
control.CurrentClassifierChoice = 1;               % Ĭ�Ϸ����� DistCompare
control.PastSplitRatioChoice = 3;
control.PastClassifierChoice = 1;
control.choiceline = [0 0 0];
control.wronglist = [];
global param;
param.fs = 8000;
param.label = 'RecordedSound';
param.startindex = 1;
param.number = 0;
global recorder;
recorder.begin = false;           % Ĭ��û�п�ʼ¼��
recorder.voice = [];
recorder.R = audiorecorder(param.fs,16,1);
global classifierparam;
classifierparam.DCtraincore = [];       % DistCompare ��ѵ��������(����)
classifierparam.NBquantizer = [];
classifierparam.NBTrainingSets = [];
classifierparam.NBValidationSets = [];

% ��ʼ��һЩ��ʾ����
set(handles.textCurrentAccuracy,'string',num2str(0,'%.3f'));
set(handles.textCurrentRecallRate,'string',num2str(0,'%.3f'));
% ��ʼ��Ĭ��ֻѡ��13��Ƶ������

set(handles.checkbox_meanpitch,'Value',1);
set(handles.checkbox_maxpitch,'Value',1);
set(handles.checkbox_minpitch,'Value',1);
set(handles.checkbox_mfcc,'Value',0);

% Ĭ�ϱ�����7:3
set(handles.MenuSeventyThirty,'Checked','on');
% Ĭ�Ϸ������� NaiveBayes ���ر�Ҷ˹
set(handles.MenuNaiveBayes,'Checked','on');

% --- Outputs from this function are returned to the command line.
function varargout = GenderRecogGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%                             1���˵���
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1-1 һ����ɣ�����·������ȡ����������ѵ����֤����ѵ��������
function MenuGetDataSets_Callback(hObject, eventdata, handles)
% hObject    handle to MenuGetDataSets (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global control;
global classifierparam;
control.datasetpath = uigetdir('','ѡ��ԭʼ���ݼ������ļ���');
if ~ischar(control.datasetpath)
    warndlg('���棡��û��ѡ���ļ��У���ѡ��ԭʼ���ݼ������ļ���','������ʾ');
else
    % ����ȡ�����Ĺ����У��������Ӧ�����ɲ���
    allWidgetEnable(handles,0);
    hs = msgbox('����ѵ��','��ʾ');
    ht = findobj(hs, 'Type', 'text');
    set(ht,'FontSize',8);
    set(hs, 'Resize', 'on');
    fprintf('������ȡ����...\n');
    %% ��ȡ·��
    control.fold_list = dir(control.datasetpath);
    %% ������ȡ
    category_num = length(control.fold_list)-2;
    % �����Ϣ�����ṹ��
    VOICES(category_num,1) = struct('name',[],'data',[],'num',[]);
    % ��ȡͼ�񵽽ṹ����
    file_list = cell(2,1);
    for i=1:category_num
        VOICES(i).name = control.fold_list(i+2).name;
        % ÿ�����е����ɸ��ļ�
        file_list{i} = dir([control.datasetpath,'\',VOICES(i).name]);
        VOICES(i).num = min(length(file_list{i})-2,20+round(5*rand()));   % �����ȡ��������
%         VOICES(i).num = length(file_list{i})-2;                            % ��������
        for j=1:VOICES(i).num
            [currentvoice,fs] = audioread([control.datasetpath,'\',VOICES(i).name,'\',file_list{i}(j+2).name]);
            allfts = myfeature(currentvoice,fs);        % ��ȡ��������
            voiced = mygetvoiced(currentvoice,fs);      % ��������ȡ����
            % �����û���ѡ����ȡ����
            feature = [];
            if get(handles.checkbox_meanpitch,'Value')==1       % ѡ���� meanpitch
                feature = [feature allfts(11)];
                control.choiceline(1) = 1;
            end
            if get(handles.checkbox_maxpitch,'Value')==1       % ѡ���� maxpitch 
                feature = [feature allfts(12)];
                control.choiceline(2) = 1;
            end
            if get(handles.checkbox_minpitch,'Value')==1       % ѡ���� minpitch 
                feature = [feature allfts(13)];
                control.choiceline(3) = 1;
            end
            if get(handles.checkbox_mfcc,'Value')==1           % ѡ���� mfcc
                feature = [feature allfts(14:26)];
            end
            if get(handles.checkbox_feature1,'Value')==1       % ѡ���� feature1 
                feature = [feature yourfeature1(voiced,fs)];
            end
            if get(handles.checkbox_feature2,'Value')==1       % ѡ���� feature2
                feature = [feature yourfeature2(voiced,fs)];
            end
            if get(handles.checkbox_feature3,'Value')==1       % ѡ���� feature3
                feature = [feature yourfeature3(voiced,fs)];
            end
            if get(handles.checkbox_feature4,'Value')==1       % ѡ���� feature4
                feature = [feature yourfeature4(voiced,fs)];
            end
            if isempty(feature)
                allWidgetEnable(handles,1);
                errordlg('����! ��������Ҫѡ��һ������','������ʾ');
                return;
            end
            VOICES(i).data(j,:) = feature;          % תΪ����������ṹ����
        end
        fprintf('��%d��/��%d������(��%d������)������ȡ���\n',i,category_num,VOICES(i).num);
    end
    control.ftsstruct = VOICES;
    fprintf('��������ȡ\n');
    %% �������ݼ�
    category_num = size(control.ftsstruct,1);
    traindata = [];
    trainlabel = [];
    valdata = [];
    vallabel = [];
    train_index_remember = [];
    for i=1:category_num
        file_num = VOICES(i).num;
        [val_index,train_index] = crossvalind('holdOut',file_num,control.TrainSegRatio);
        traindata = [traindata;VOICES(i).data(train_index,:)];
        trainlabel = [trainlabel;i*ones(sum(train_index),1)];
        valdata = [valdata;VOICES(i).data(val_index,:)];
        vallabel = [vallabel;i*ones(sum(val_index),1)];
        train_index_remember = [train_index_remember;train_index];
    end
    % һЩ����
    male_train_num = sum(train_index_remember(1:size(VOICES(1).data,1)));
    male_val_num = size(VOICES(1).data,1) - male_train_num;
    female_train_num = sum( train_index_remember(size(VOICES(1).data,1)+1:end) );
    female_val_num = size(VOICES(2).data,1) - female_train_num;
    
    control.traindata = traindata;
    control.trainlabel = trainlabel;
    control.valdata = valdata;
    control.vallabel = vallabel;
    fprintf('ѵ����/��֤���������\n');
    %% ѵ��
    % ��ʼѵ��������
    if strcmp(control.classifier,'DistCompare')==1
        % ѵ������
        Results = myDistDetermine(control.traindata,control.trainlabel,control.valdata);
        cfsmtx = mycfsmtx(control.vallabel,Results.predicted_label);
        % ��ʶ���������ݵ�����ҵ�
        control.wronglist = find((control.vallabel-Results.predicted_label)~=0);
        % ���ݱ���
        classifierparam.DCtraincore = Results.DCtraincore;
        % �����ʾ
        control.ValCorrRate = cfsmtx(end,end);             % ׼ȷ��
        control.RecallRate = cfsmtx(1,end);             % �ٻ���
        set(handles.textCurrentAccuracy,'string',num2str(control.ValCorrRate,'%.3f'));
        set(handles.textCurrentRecallRate,'string',num2str(control.RecallRate,'%.3f'));
    elseif strcmp(control.classifier,'NaiveBayes')==1
        % ����Ԥ����
        ftsnum = size(control.traindata,2);     % ������ֵ
        traindata_qualify = zeros(size(control.traindata));
        valdata_qualify = zeros(size(control.valdata));
        for i=1:ftsnum
            traindata_qualify(:,i) = mydiscretization(control.traindata(:,i),control.ftsRange);     % ������ֵ������ftsRange = 20;
            valdata_qualify(:,i) = mydiscretization(control.valdata(:,i),control.ftsRange);
        end
        % ѵ������
        [TrainingSets,ValidationSets] = myNaiveBayesTrain(traindata_qualify,control.trainlabel,...
            valdata_qualify,control.vallabel,control.ftsRange);
        predicted_label = myNaiveBayesValidation(TrainingSets,ValidationSets);
        cfsmtx = mycfsmtx(control.vallabel,predicted_label);
        % ��ʶ���������ݵ�����ҵ�
        control.wronglist = find((control.vallabel-predicted_label)~=0);
        % ���ݱ���
        classifierparam.NBTrainingSets = TrainingSets;
        classifierparam.NBValidationSets = ValidationSets;
        % �����ʾ
        control.ValCorrRate = cfsmtx(end,end);             % ׼ȷ��
        control.RecallRate = cfsmtx(1,end);             % �ٻ���
        set(handles.textCurrentAccuracy,'string',num2str(control.ValCorrRate,'%.3f'));
        set(handles.textCurrentRecallRate,'string',num2str(control.RecallRate,'%.3f'));
    elseif strcmp(control.classifier,'KMSKNN')==1
        % ����Ԥ����
        train_class_num = mynumstatistic(control.trainlabel);
        train_female_num = train_class_num(1,2);
        train_male_num = train_class_num(2,2);
        [~,traindata_new_f,~,~,~] = mykmeans( control.traindata(1:train_female_num,:),control.clusters );       % clusters = 100;
        [~,traindata_new_m,~,~,~] = mykmeans( control.traindata(train_female_num+1:train_female_num+train_male_num,:),control.clusters );
        traindata_new = [traindata_new_f;traindata_new_m];
        trainlabel_new = [ones(control.clusters,1);2*ones(control.clusters,1)];
        % ѵ������
        KMSKNN_model = fitcknn(traindata_new,trainlabel_new,'NumNeighbors',control.Knearest); % Knearest=12
        predicted_label = KMSKNN_model.predict(control.valdata);
        cfsmtx = mycfsmtx(control.vallabel,predicted_label);
        % ��ʶ���������ݵ�����ҵ�
        control.wronglist = find((control.vallabel-predicted_label)~=0);
        % ���ݱ���
        classifierparam.KMSKNNmodel = KMSKNN_model;
        % �����ʾ
        control.ValCorrRate = cfsmtx(end,end);             % ׼ȷ��
        control.RecallRate = cfsmtx(1,end);             % �ٻ���
        set(handles.textCurrentAccuracy,'string',num2str(control.ValCorrRate,'%.3f'));
        set(handles.textCurrentRecallRate,'string',num2str(control.RecallRate,'%.3f'));
    elseif strcmp(control.classifier,'KNN')==1
        % ѵ������
        KNN_model = fitcknn(control.traindata,control.trainlabel,'NumNeighbors',7); 
        predicted_label = KNN_model.predict(control.valdata);
        cfsmtx = mycfsmtx(control.vallabel,predicted_label);
        % ��ʶ���������ݵ�����ҵ�
        control.wronglist = find((control.vallabel-predicted_label)~=0);
        % ���ݱ���
        classifierparam.KNNmodel = KNN_model;
        % �����ʾ
        control.ValCorrRate = cfsmtx(end,end);             % ׼ȷ��
        control.RecallRate = cfsmtx(1,end);             % �ٻ���
        set(handles.textCurrentAccuracy,'string',num2str(control.ValCorrRate,'%.3f'));
        set(handles.textCurrentRecallRate,'string',num2str(control.RecallRate,'%.3f'));
    elseif strcmp(control.classifier,'SVM')==1
        % Ѱ��Ԥ����(��Ѱ��+��Ѱ��)
        [cmin,cmax,gmin,gmax,v,cstep,gstep,accstep] = deal(-15,15,-15,15,3,2,2,2);
        [~,c_temp,g_temp] = SVMcgForClass(control.trainlabel,control.traindata,cmin,cmax,gmin,gmax,v,cstep,gstep,accstep);
        [cmin,cmax,gmin,gmax,v,cstep,gstep,accstep] = deal(log(c_temp)/log(2)-2,log(c_temp)/log(2)+2,...
            log(g_temp)/log(2)-2,log(g_temp)/log(2)+2,3,0.25,0.25,0.5);
        [~,bestc,bestg] = SVMcgForClass(control.trainlabel,control.traindata,cmin,cmax,gmin,gmax,v,cstep,gstep,accstep);
        % ѵ������
        cmd = [' -s ',num2str(0),' -c ',num2str(bestc),' -g ',num2str(bestg)];
        svm_model = svmtrain(control.trainlabel,control.traindata,cmd);
        [predicted_label, ~, ~] = svmpredict(control.vallabel,control.valdata,svm_model);
        cfsmtx = mycfsmtx(control.vallabel,predicted_label);
        % ��ʶ���������ݵ�����ҵ�
        control.wronglist = find((control.vallabel-predicted_label)~=0);
        % ���ݱ���
        classifierparam.SVMmodel = svm_model;
        % �����ʾ
        control.ValCorrRate = cfsmtx(end,end);             % ׼ȷ��
        control.RecallRate = cfsmtx(1,end);             % �ٻ���
        set(handles.textCurrentAccuracy,'string',num2str(control.ValCorrRate,'%.3f'));
        set(handles.textCurrentRecallRate,'string',num2str(control.RecallRate,'%.3f'));
    else
        errordlg('���󣡸÷�����������','������ʾ');
    end
    % ѵ����������ɣ��ָ����Ŀɲ�����
    allWidgetEnable(handles,1);
    % ��ʾ��Ϣ
    fprintf('ѵ�����\n');
    hs = msgbox('ѵ�����','��ʾ');
    ht = findobj(hs, 'Type', 'text');
    set(ht,'FontSize',8);
    set(hs, 'Resize', 'on');
    
    %% ѵ��������ĵ�һ���£��ҵ����������������
    % �ҵ���������������ţ�ֻ����֤����
%     control.wronglist
    findval_index = find(train_index_remember==0);
    findvalwrong_index = findval_index(control.wronglist);
    findfemalevalwrong_index = findvalwrong_index(findvalwrong_index<=VOICES(1).num);
    findmalevalwrong_index = findvalwrong_index(findvalwrong_index>VOICES(1).num);
    findmalevalwrong_index = findmalevalwrong_index-VOICES(1).num;
    % ��ɾ���ļ�����ԭ�����ڵ��ļ�
    delete([pwd,'\GUIClassWrng\female\*.*']);
    delete([pwd,'\GUIClassWrng\male\*.*']);
    % ���������������������ļ�����
    for i=1:length(findfemalevalwrong_index)
        source = [control.datasetpath,'\female\',file_list{1,1}(findfemalevalwrong_index(i)+2).name];
        destination = 'GUIClassWrng\female\';
        copyfile(source,destination);
    end
    for i=1:length(findmalevalwrong_index)
        source = [control.datasetpath,'\male\',file_list{2,1}(findmalevalwrong_index(i)+2).name];
        destination = 'GUIClassWrng\male\';
        copyfile(source,destination);
    end
    %% ѵ���׶Σ���ѡ�����ľ�̬�ı����м䣩һ�ɲ���ʾ��������
    % 11 text_meanpitch
    if control.choiceline(1)==1
        set(handles.text_meanpitch,'string','meanpitch');
    else
        set(handles.text_meanpitch,'string','����');
    end
    % 12 text_maxpitch
    if control.choiceline(2)==1
        set(handles.text_maxpitch,'string','maxpitch');
    else
        set(handles.text_maxpitch,'string','����');
    end
    % 13 text_minpitch
    if control.choiceline(3)==1
        set(handles.text_minpitch,'string','minpitch');  
    else
        set(handles.text_minpitch,'string','����');
    end
    
    %% ѵ���׶Σ���ѡ�����ľ�̬�ı������£���ʾ��Ů���ڴ����ϵľ�ֵ
    TraindataSelected4male = control.traindata;
    TraindataSelected4male(control.trainlabel==1,:) = [];
    TraindataSelected4male = mean(TraindataSelected4male);
    TraindataSelected4female = control.traindata;
    TraindataSelected4female(control.trainlabel==2,:) = [];
    TraindataSelected4female = mean(TraindataSelected4female);
    
    temp_TraindataSelected4male = TraindataSelected4male;
    temp_TraindataSelected4female = TraindataSelected4female;
    if control.choiceline(1) == 1
        set(handles.textM1,'string',num2str(temp_TraindataSelected4male(1)));
        set(handles.textF1,'string',num2str(temp_TraindataSelected4female(1)));
        temp_TraindataSelected4male(1) = [];
        temp_TraindataSelected4female(1) = [];
    else
        set(handles.textM1,'string','����');
        set(handles.textF1,'string','����');
    end
    if control.choiceline(2) == 1
        set(handles.textM2,'string',num2str(temp_TraindataSelected4male(1)));
        set(handles.textF2,'string',num2str(temp_TraindataSelected4female(1)));
        temp_TraindataSelected4male(1) = [];
    else
        set(handles.textM2,'string','����');
        set(handles.textF2,'string','����');
        set(handles.text_maxpitch,'string','����');
    end
    if control.choiceline(3) == 1
        set(handles.textM3,'string',num2str(temp_TraindataSelected4male(1)));
        set(handles.textF3,'string',num2str(temp_TraindataSelected4female(1)));
    else
        set(handles.textM3,'string','����');
        set(handles.textF3,'string','����');
    end
    clear temp_TraindataSelected4male;
    clear temp_TraindataSelected4female;

    %% ��־λ
    % ѵ�����������������ı��־λ����
    control.featurechanged = zeros(1,8);
    % ѵ��������ѡ��Ļ��ֱ����� current ״̬��Ϊ past����ǰ�����һ�֣�
    control.PastSplitRatioChoice = control.CurrentSplitRatioChoice;
    control.PastClassifierChoice = control.CurrentClassifierChoice;
end

% % 1-2 ��������--------------------------------------------------------------------
% function MenuGetVoice_Callback(hObject, eventdata, handles)
% % hObject    handle to MenuGetVoice (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)


% 3-1-1 ѡ��ѵ��������Ϊ50% -------------------------------------------
function MenuFiftyFifty_Callback(hObject, eventdata, handles)
% hObject    handle to MenuFiftyFifty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global control;
control.TrainSegRatio = 0.5;
set(handles.MenuFiftyFifty,'Checked','on');     % ǰ���
set(handles.MenuSixtyForty,'Checked','off');
set(handles.MenuSeventyThirty,'Checked','off');
set(handles.MenuEightyTwenty,'Checked','off');
set(handles.MenuNintyTen,'Checked','off');
control.CurrentSplitRatioChoice = 1;


% 3-1-2 ѡ��ѵ��������Ϊ60% -------------------------------------------
function MenuSixtyForty_Callback(hObject, eventdata, handles)
% hObject    handle to MenuSixtyForty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global control;
control.TrainSegRatio = 0.6;
set(handles.MenuFiftyFifty,'Checked','off');    
set(handles.MenuSixtyForty,'Checked','on');     % ǰ���
set(handles.MenuSeventyThirty,'Checked','off');
set(handles.MenuEightyTwenty,'Checked','off');
set(handles.MenuNintyTen,'Checked','off');
control.CurrentSplitRatioChoice = 2;

% 3-1-3 ѡ��ѵ��������Ϊ70% ------------------------------------------
function MenuSeventyThirty_Callback(hObject, eventdata, handles)
% hObject    handle to MenuSeventyThirty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global control;
control.TrainSegRatio = 0.7;
set(handles.MenuFiftyFifty,'Checked','off');     
set(handles.MenuSixtyForty,'Checked','off');
set(handles.MenuSeventyThirty,'Checked','on');      % ǰ���
set(handles.MenuEightyTwenty,'Checked','off');
set(handles.MenuNintyTen,'Checked','off');
control.CurrentSplitRatioChoice = 3;

% 3-1-4 ѡ��ѵ��������Ϊ80% ------------------------------------------
function MenuEightyTwenty_Callback(hObject, eventdata, handles)
% hObject    handle to MenuEightyTwenty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global control;
control.TrainSegRatio = 0.8;
set(handles.MenuFiftyFifty,'Checked','off');     
set(handles.MenuSixtyForty,'Checked','off');
set(handles.MenuSeventyThirty,'Checked','off');
set(handles.MenuEightyTwenty,'Checked','on');       % ǰ���
set(handles.MenuNintyTen,'Checked','off');
control.CurrentSplitRatioChoice = 4;

% 3-1-5 ѡ��ѵ��������Ϊ90% -------------------------------------------
function MenuNintyTen_Callback(hObject, eventdata, handles)
% hObject    handle to MenuNintyTen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global control;
control.TrainSegRatio = 0.9;
set(handles.MenuFiftyFifty,'Checked','off');
set(handles.MenuSixtyForty,'Checked','off');
set(handles.MenuSeventyThirty,'Checked','off');
set(handles.MenuEightyTwenty,'Checked','off');
set(handles.MenuNintyTen,'Checked','on');       % ǰ���
control.CurrentSplitRatioChoice = 5;

% 3-2-1 ѡ�������Ϊ DistCompare --------------------------------------
function MenuDistCompare_Callback(hObject, eventdata, handles)
% hObject    handle to MenuDistCompare (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global control;
control.classifier = 'DistCompare';
set(handles.MenuDistCompare,'Checked','on');     % ǰ���
set(handles.MenuNaiveBayes,'Checked','off');
set(handles.MenuKMSKNN,'Checked','off');
set(handles.MenuKNN,'Checked','off');
set(handles.MenuSVM,'Checked','off');      
control.CurrentClassifierChoice = 1;                  % Ĭ�Ϸ����� DistCompare

% 3-2-2 ѡ�������Ϊ NaiveBayes ---------------------------------------
function MenuNaiveBayes_Callback(hObject, eventdata, handles)
% hObject    handle to MenuNaiveBayes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global control;
control.classifier = 'NaiveBayes';
set(handles.MenuDistCompare,'Checked','off');
set(handles.MenuNaiveBayes,'Checked','on');    % ǰ���
set(handles.MenuKMSKNN,'Checked','off');
set(handles.MenuKNN,'Checked','off');
set(handles.MenuSVM,'Checked','off');       
control.CurrentClassifierChoice = 2;

% 3-2-3 ѡ�������Ϊ KMSKNN --------------------------------------------
function MenuKMSKNN_Callback(hObject, eventdata, handles)
% hObject    handle to MenuKMSKNN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global control;
control.classifier = 'KMSKNN';
set(handles.MenuDistCompare,'Checked','off');
set(handles.MenuNaiveBayes,'Checked','off');
set(handles.MenuKMSKNN,'Checked','on');     % ǰ���
set(handles.MenuKNN,'Checked','off');
set(handles.MenuSVM,'Checked','off');       
control.CurrentClassifierChoice = 3;

% 3-2-4 ѡ�������Ϊ KNN ---------------------------------------------
function MenuKNN_Callback(hObject, eventdata, handles)
% hObject    handle to MenuKNN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global control;
control.classifier = 'KNN';
set(handles.MenuDistCompare,'Checked','off');
set(handles.MenuNaiveBayes,'Checked','off');
set(handles.MenuKMSKNN,'Checked','off');
set(handles.MenuKNN,'Checked','on');        % ǰ���
set(handles.MenuSVM,'Checked','off');
control.CurrentClassifierChoice = 4;

% 3-2-5 ѡ�������Ϊ SVM --------------------------------------------
function MenuSVM_Callback(hObject, eventdata, handles)
% hObject    handle to MenuSVM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global control;
control.classifier = 'SVM';
set(handles.MenuDistCompare,'Checked','off');
set(handles.MenuNaiveBayes,'Checked','off');
set(handles.MenuKMSKNN,'Checked','off');
set(handles.MenuKNN,'Checked','off');
set(handles.MenuSVM,'Checked','on');       % ǰ���
control.CurrentClassifierChoice = 5;

% 4-1 ���ʹ�ð���------------------------------------------------------
function MenuGuide_Callback(hObject, eventdata, handles)
% hObject    handle to MenuGuide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hs = msgbox({'���ʹ�ð���:';...
            '����һ����׵������Ա�ʶ��������������¹��ܣ�';'';...
            '1. �����߽������û��Լ�����ɣ���';...
            '2. ...��';...
            '3. ...��';...
            '4. ...��';...
            '4. ...��';'';...
            '���У�...��';...
            '        ...';'        ...';'        ...';...
            '        ...';'';...
            '�����...��������';
            '        ...';...
            '        ...';...
            '        ...';...
            '        ...';...
            '        ...';...
            '        ...';...
            },'UserGuide');
%�ı������С
ht = findobj(hs, 'Type', 'text');
set(ht,'FontSize',8);
%�ı�Ի����С
set(hs, 'Resize', 'on'); 

% 4-2 ����汾˵��-----------------------------------------------------
function MenuVersion_Callback(hObject, eventdata, handles)
% hObject    handle to MenuVersion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hs = msgbox({'����汾˵��:';'';'Version: 0.2 ';'';...
             'Author: Chen Tianyang';'';...
             'Data:2019-03-20';''},'Version Information');
%�ı������С
ht = findobj(hs, 'Type', 'text');
set(ht,'FontSize',8);
%�ı�Ի����С
set(hs, 'Resize', 'on'); 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%                             2��������
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --------------------------------------------------------------------
function showgrid_OnCallback(hObject, eventdata, handles)
% hObject    handle to showgrid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes_time);
grid on;

% --------------------------------------------------------------------
function showgrid_OffCallback(hObject, eventdata, handles)
% hObject    handle to showgrid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes_time);
grid off;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%                        3�� ����ָ��                       
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- �鿴�������Ľ�� ���ļ��ж�ȡ����
function pushbutton_check_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global recorder;
global param;
[filename,pathname] = uigetfile({'*.wav';'*.mp3';'*.ogg';'*.au';'*.flac'},...
    'Select a voice file',[pwd,'\GUIClassWrng\']);
if ischar(filename) && ischar(pathname)
    [x,fs] = audioread([pathname,filename]);
    x = resample(x,8000,fs);
    fs = 8000;
    x = x/max(abs(x));
    recorder.voice = x;
    param.fs = fs;
    % ��ͼ
    axes(handles.axes_time);
    t = (0:length(x)-1)/fs;
    plot(t,x);xlabel('Time/s');ylabel('Amplitude');title('Speech waveform');
    % ��ʾ���Ľ��ۺ��������
    set(handles.textCurrentGender,'String','�Ա�');
    % 11 text_meanpitch
    set(handles.text_meanpitch,'string','meanpitch');
    % 12 text_maxpitch
    set(handles.text_maxpitch,'string','maxpitch');
    % 13 text_minpitch
    set(handles.text_minpitch,'string','minpitch');  
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%                         4�������Ա�ʶ��                      
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1 ��ʼ/¼����ť --------------------------------------------------------
function StartRecord_Callback(hObject, eventdata, handles)
% hObject    handle to StartRecord (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global recorder;
global param;
% ¼���У���岻�ɲ���
allWidgetEnable(handles,0);
if recorder.begin == false
    recorder.begin = true;
    recorder.R = audiorecorder(param.fs,16,1);
    record(recorder.R); %��ʼ¼��
    set(handles.StartRecord,'string','ֹͣ');
    set(handles.StartRecord,'enable','on');
    return;
else
    recorder.begin = false;
    stop(recorder.R); 
    recorder.voice = getaudiodata(recorder.R);
    index = param.startindex+param.number;
    folder = [pwd,'\recorder'];
    if ~isdir(folder)
        mkdir(folder);
    end
    filename = [folder,'\',param.label,'_',num2str(index),'.wav'];
    audiowrite(filename,recorder.voice,param.fs);
    param.number = param.number+1;       
    set(handles.StartRecord,'string','¼��');
    % ��ͼ
    axes(handles.axes_time);
    t = (0:length(recorder.voice)-1)/param.fs;
    plot(t,recorder.voice);xlabel('Time/s');ylabel('Amplitude');title('Speech waveform');
end
% ¼����ϣ����ָ���������
allWidgetEnable(handles,1);
% ��ʾ���Ľ��ۺ��������
set(handles.textCurrentGender,'String','�Ա�');
% 11 text_meanpitch
set(handles.text_meanpitch,'string','meanpitch');
% 12 text_maxpitch
set(handles.text_maxpitch,'string','maxpitch');
% 13 text_minpitch
set(handles.text_minpitch,'string','minpitch');  

% 2 �˵���-�������� / �ӱ��ؼ��������źŰ�ť --------------------------------------------
function ChooseRecord_Callback(hObject, eventdata, handles)
% hObject    handle to ChooseRecord (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global recorder;
global param;
[filename,pathname] = uigetfile({'*.wav';'*.mp3';'*.ogg';'*.au';'*.flac'},'Select a voice file');
if ischar(filename)&&ischar(pathname)
    [x,fs] = audioread([pathname,filename]);
    if fs ~= 8000
        x = resample(x,8000,fs);
        fs = 8000;
    end
    x = x/max(abs(x));
    recorder.voice = x;
    param.fs = fs;
    % ��ͼ
    axes(handles.axes_time);
    t = (0:length(x)-1)/fs;
    plot(t,x);xlabel('Time/s');ylabel('Amplitude');title('Speech waveform');
    % ��ʾ����4���ؼ��ϵĽ��ۺ��������(11 text_meanpitch��12 text_maxpitch��13 text_minpitch)
    set(handles.textCurrentGender,'String','�Ա�');
    set(handles.text_meanpitch,'string','meanpitch');
    set(handles.text_maxpitch,'string','maxpitch');
    set(handles.text_minpitch,'string','minpitch');  
    % ��ʾ��Ϣ
    hs = msgbox('���������Ѷ�ȡ���','��ʾ');
    ht = findobj(hs, 'Type', 'text');     
    set(ht,'FontSize',8);     
    set(hs, 'Resize', 'on'); 
else
    warndlg('���棡��û��ѡ����������ļ�����ѡ����һ�����ļ�','������ʾ');
end

% 3 ʶ����ź�����������Ů�� ----------------------------------------------
function pushbuttonGoJudge_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonGoJudge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global recorder;
global param;
global control;
global classifierparam;
if isempty(recorder.voice)
    errordlg('����û�з�������������¼�����ȡ��������','������ʾ');
elseif sum(control.featurechanged)~=0
    errordlg('������������Ѹı䣬��������ѵ��','������ʾ');
elseif control.CurrentSplitRatioChoice ~= control.PastSplitRatioChoice
    errordlg('����ѵ������֤�������Ѹı䣬��������ѵ��','������ʾ');
elseif control.CurrentClassifierChoice ~= control.PastClassifierChoice
    errordlg('���󣡷������Ѹı䣬��������ѵ��','������ʾ');
else
    allfts = myfeature(recorder.voice,param.fs);        % ��ȡ��������
    voiced = mygetvoiced(recorder.voice,param.fs);      % ��������ȡ����
    % �����û���ѡ����ȡ����
    feature = [];
    if get(handles.checkbox_meanpitch,'Value')==1       % ѡ���� meanpitch 
        feature = [feature allfts(11)];
    end
    if get(handles.checkbox_maxpitch,'Value')==1       % ѡ���� maxpitch 
        feature = [feature allfts(12)];
    end
    if get(handles.checkbox_minpitch,'Value')==1       % ѡ���� minpitch 
        feature = [feature allfts(13)];
    end
    if get(handles.checkbox_mfcc,'Value')==1           % ѡ���� minpitch 
        feature = [feature allfts(14:26)];
    end
    if get(handles.checkbox_feature1,'Value')==1       % ѡ���� feature1 
        feature = [feature myfeature1(voiced,fs)];
    end
    if get(handles.checkbox_feature2,'Value')==1       % ѡ���� feature2
        feature = [feature myfeature2(voiced,fs)];
    end
    if get(handles.checkbox_feature3,'Value')==1       % ѡ���� feature3
        feature = [feature myfeature3(voiced,fs)];
    end
    if get(handles.checkbox_feature4,'Value')==1       % ѡ���� feature4
        feature = [feature myfeature4(voiced,fs)];
    end    
    % �жϲ��Ե�������ѵ��/��֤�������Ƿ�һ��
    % �жϵ�ǰ���õ������ַ�����
    if strcmp(control.classifier,'DistCompare')==1
        if isempty(classifierparam.DCtraincore)
            errordlg('����Dist Comapre ������������,����ѵ���˷�����','������ʾ');
        else
            % DistCompare ���
            predicted_label = myDistDetermineTest(classifierparam.DCtraincore,feature);
            if predicted_label==1
                set(handles.textCurrentGender,'string','Ů');
            else
                set(handles.textCurrentGender,'string','��');
            end
        end
    elseif strcmp(control.classifier,'NaiveBayes')==1
        if isempty(classifierparam.NBTrainingSets)||isempty(classifierparam.NBValidationSets)
            errordlg('����Naive Bayes ������������,����ѵ���˷�����','������ʾ');
        else 
            % ���ȴ� NBTrainingSets �еó�ÿ�������������Сֵ
            feature_max = max([control.traindata;control.valdata]);
            feature_min = min([control.traindata;control.valdata]);
            % �Դ�Ϊ���ݶ�������������������
            feature_qualify = mydiscretization2(feature_max,feature_min,control.ftsRange,feature);
            % NaiveBayes ���
            [predicted_label,female_prob,male_prob] = myNaiveBayesTest(classifierparam.NBTrainingSets,feature_qualify);
            if predicted_label==1
                set(handles.textCurrentGender,'string','Ů');
            else
                set(handles.textCurrentGender,'string','��');
            end
            set(handles.text_PF,'string',num2str(female_prob));
            set(handles.text_PM,'string',num2str(male_prob));
        end
    elseif strcmp(control.classifier,'KMSKNN')==1
        if isempty(classifierparam.KMSKNNmodel)
            errordlg('����KMSKNN ������������,����ѵ���˷�����','������ʾ');
        else
            KMSKNN_model = classifierparam.KMSKNNmodel;
            predicted_label = KMSKNN_model.predict(feature);
            if predicted_label==1
                set(handles.textCurrentGender,'string','Ů');
            else
                set(handles.textCurrentGender,'string','��');
            end
        end
    elseif strcmp(control.classifier,'KNN')==1
        if isempty(classifierparam.KNNmodel)
            errordlg('����KNN ������������,����ѵ���˷�����','������ʾ');
        else
            KNN_model = classifierparam.KNNmodel;
            predicted_label = KNN_model.predict(feature);
            if predicted_label==1
                set(handles.textCurrentGender,'string','Ů');
            else
                set(handles.textCurrentGender,'string','��');
            end
        end
    elseif strcmp(control.classifier,'SVM')==1
        if isempty(classifierparam.SVMmodel)
            errordlg('����SVM ������������,����ѵ���˷�����','������ʾ');
        else
            % ����
            [predicted_label, ~, ~] = svmpredict(1,feature,classifierparam.SVMmodel);   % ��һ������"1"�Ǵ��ж����ݵ�α��ǩ
            if predicted_label==1
                set(handles.textCurrentGender,'string','Ů');
            else
                set(handles.textCurrentGender,'string','��');
            end
        end
    else
        errordlg('���󣡸÷�����������','������ʾ');
    end
    currentfeature = feature;
    if control.choiceline(1)==1
        set(handles.text_meanpitch,'string',num2str(currentfeature(1)));
        currentfeature(1) = [];
    else
        set(handles.text_meanpitch,'string','����');
    end
    if control.choiceline(2)==1
        set(handles.text_maxpitch,'string',num2str(currentfeature(1)));
        currentfeature(1) = [];
    else
        set(handles.text_maxpitch,'string','����');
    end
    if control.choiceline(3)==1
        set(handles.text_minpitch,'string',num2str(currentfeature(1)));
    else
        set(handles.text_minpitch,'string','����');
    end
    clear currentfeature;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%                         5���������
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in pushbuttonPlay.
function pushbuttonPlay_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPlay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global recorder;
global param;
if ~isempty(recorder.voice)&&~isempty(param.fs)
    sound(recorder.voice,param.fs);
end
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%                         6������ѡ��
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- 1 meanpitch.
function checkbox_meanpitch_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_meanpitch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_meanpitch
global control;
if control.featurechanged(1)==0
    control.featurechanged(1) = 1;
else
    control.featurechanged(1) = 0;
end
if get(hObject,'value')==1
    control.choiceline(1) = 1;
else
    control.choiceline(1) = 0;
end

% --- 2 maxpitch.
function checkbox_maxpitch_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_maxpitch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_maxpitch
global control;
if control.featurechanged(2)==0
    control.featurechanged(2) = 1;
else
    control.featurechanged(2) = 0;
end
if get(hObject,'value')==1
    control.choiceline(2) = 1;
else
    control.choiceline(2) = 0;
end

% --- 3 minpitch.
function checkbox_minpitch_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_minpitch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_minpitch
global control;
if control.featurechanged(3)==0
    control.featurechanged(3) = 1;
else
    control.featurechanged(3) = 0;
end
if get(hObject,'value')==1
    control.choiceline(3) = 1;
else
    control.choiceline(3) = 0;
end

% --- 4 mfcc.
function checkbox_mfcc_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_mfcc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_mfcc
global control;
if control.featurechanged(4)==0
    control.featurechanged(4) = 1;
else
    control.featurechanged(4) = 0;
end

% --- 5 feature1.
function checkbox_feature1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_feature1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_feature1
global control;
if control.featurechanged(5)==0
    control.featurechanged(5) = 1;
else
    control.featurechanged(5) = 0;
end

% --- 6 feature2.
function checkbox_feature2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_feature2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_feature2
global control;
if control.featurechanged(6)==0
    control.featurechanged(6) = 1;
else
    control.featurechanged(6) = 0;
end

% --- 7 feature3.
function checkbox_feature3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_feature3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_feature3
global control;
if control.featurechanged(7)==0
    control.featurechanged(7) = 1;
else
    control.featurechanged(7) = 0;
end

% --- 8 feature4.
function checkbox_feature4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_feature4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_feature4
global control;
if control.featurechanged(8)==0
    control.featurechanged(8) = 1;
else
    control.featurechanged(8) = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%                         7��ɨβ����
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
rmpath(genpath([pwd,'\myfunctions']));
rmpath(genpath([pwd,'\libsvm322']));
disp('Exit GendeRecogGUI');
delete(hObject);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%                         8������������������
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function allWidgetEnable(handles,enable)
if enable == 1
    set(handles.textCurrentAccuracy,'enable','on');
    set(handles.textCurrentRecallRate,'enable','on');
    set(handles.pushbutton_check,'enable','on');
    set(handles.StartRecord,'enable','on');
    set(handles.ChooseRecord,'enable','on');
    set(handles.pushbuttonGoJudge,'enable','on');
    set(handles.pushbuttonPlay,'enable','on');
    set(handles.textCurrentGender,'enable','on');

    set(handles.text_PM,'enable','on');
    set(handles.text_PF,'enable','on');
    set(handles.checkbox_meanpitch,'enable','on');
    set(handles.checkbox_maxpitch,'enable','on');
    set(handles.checkbox_minpitch,'enable','on');
    set(handles.checkbox_mfcc,'enable','on');
    set(handles.checkbox_feature1,'enable','on');
    set(handles.checkbox_feature2,'enable','on');
    set(handles.checkbox_feature3,'enable','on');
    set(handles.checkbox_feature4,'enable','on');

    set(handles.text_meanpitch,'enable','on');
    set(handles.text_maxpitch,'enable','on');
    set(handles.text_minpitch,'enable','on');
    
    set(handles.RecordTip,'enable','on');

    set(handles.textM1,'enable','on');
    set(handles.textM2,'enable','on');
    set(handles.textM3,'enable','on');

    set(handles.textF1,'enable','on');
    set(handles.textF2,'enable','on');
    set(handles.textF3,'enable','on');
    
    set(handles.textmeanmale1,'enable','on');
    set(handles.textmeanmale2,'enable','on');
    set(handles.textmeanmale3,'enable','on');

    set(handles.textmeanfemale1,'enable','on');
    set(handles.textmeanfemale2,'enable','on');
    set(handles.textmeanfemale3,'enable','on');
    
    set(handles.textcurrent1,'enable','on');
    set(handles.textcurrent2,'enable','on');
    set(handles.textcurrent3,'enable','on');

else
    set(handles.textCurrentAccuracy,'enable','off');
    set(handles.textCurrentRecallRate,'enable','off');
    set(handles.pushbutton_check,'enable','off');
    set(handles.StartRecord,'enable','off');
    set(handles.ChooseRecord,'enable','off');
    set(handles.pushbuttonGoJudge,'enable','off');
    set(handles.pushbuttonPlay,'enable','off');
    set(handles.textCurrentGender,'enable','off');

    set(handles.text_PM,'enable','off');
    set(handles.text_PF,'enable','off');
    set(handles.checkbox_meanpitch,'enable','off');
    set(handles.checkbox_maxpitch,'enable','off');
    set(handles.checkbox_minpitch,'enable','off');
    set(handles.checkbox_mfcc,'enable','off');
    set(handles.checkbox_feature1,'enable','off');
    set(handles.checkbox_feature2,'enable','off');
    set(handles.checkbox_feature3,'enable','off');
    set(handles.checkbox_feature4,'enable','off');
    
    set(handles.text_meanpitch,'enable','off');
    set(handles.text_maxpitch,'enable','off');
    set(handles.text_minpitch,'enable','off');
    
    set(handles.RecordTip,'enable','off');

    set(handles.textM1,'enable','off');
    set(handles.textM2,'enable','off');
    set(handles.textM3,'enable','off');

    set(handles.textF1,'enable','off');
    set(handles.textF2,'enable','off');
    set(handles.textF3,'enable','off');
    
    set(handles.textmeanmale1,'enable','off');
    set(handles.textmeanmale2,'enable','off');
    set(handles.textmeanmale3,'enable','off');

    set(handles.textmeanfemale1,'enable','off');
    set(handles.textmeanfemale2,'enable','off');
    set(handles.textmeanfemale3,'enable','off');
    
    set(handles.textcurrent1,'enable','off');
    set(handles.textcurrent2,'enable','off');
    set(handles.textcurrent3,'enable','off');
end

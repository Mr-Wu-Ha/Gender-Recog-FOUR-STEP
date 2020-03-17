% Name:     S1FeatureExtraction.m
% Function: Extract features of a certain voice dataset.

% Copyright (c) 2019 CHEN Tianyang
% more info contact: tychen@whu.edu.cn

%% ׼������
clear;close all;
addpath(genpath([pwd,'\myfunctions']));
addpath(genpath([pwd,'\libsvm322']));

%% ��ȡ�������洢 - �ṹ��
predir = uigetdir();
fold_list = dir(predir);
category_num = length(fold_list)-2;
% �����Ϣ�����ṹ��
VOICES(category_num,1) = struct('name',[],'data',[],'num',[]);
% ��ȡͼ�񵽽ṹ����
fts_num = 13;       % ��ȡ��������Ŀ(��ѡ����: 1-39)
for i=1:category_num
    VOICES(i).name = fold_list(i+2).name;
    % ÿ�����е����ɸ��ļ�
    file_list = dir([predir,'\',VOICES(i).name]);
%     VOICES(i).num = min(length(file_list)-2,50+round(10*rand()));   % �����ȡ
    VOICES(i).num = length(file_list)-2;                            % ��������
    VOICES(i).data = zeros(VOICES(i).num,fts_num);
    for j=1:VOICES(i).num
        [currentvoice,fs] = audioread([predir,'\',VOICES(i).name,'\',file_list(j+2).name]);
        feature = myfeature(currentvoice,fs);       % ��ȡ��������,�õ�������
        VOICES(i).data(j,:) = feature(1:fts_num);               % ����ṹ����
    end
    fprintf('��%d��/��%d������(��%d������)������ȡ���\n',i,category_num,VOICES(i).num);
end
save('database\struct_freqfts','VOICES');
fprintf('�����Ѵ洢\n');
% figure;
% h1 = histogram(VOICES(1).data);hold on;
% h2 = histogram(VOICES(2).data);
% h1.FaceColor = 'r';h1.Normalization = 'probability';h1.BinWidth = 1;
% h2.FaceColor = 'b';h2.Normalization = 'probability';h2.BinWidth = 1;
% legend('female','male');
% xlabel('pitch/Hz');ylabel('Probability');title('Pitch Distribution for male and female ');

%% ɨβ
rmpath([pwd,'\myfunctions']);
rmpath(genpath([pwd,'\libsvm322']));
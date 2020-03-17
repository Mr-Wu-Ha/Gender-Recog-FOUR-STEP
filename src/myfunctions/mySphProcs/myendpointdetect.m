function varargout = myendpointdetect(frame,fs,st_energy,st_zerorate,thresh,noverlap,pattern,disp)
%GETSPEECH - extract speech signal by the time domain feature
%
%   label = myendpointdetect(frame,fs,st_energy,st_zerorate,[thresm,thresz])
%   label = myendpointdetect(frame,fs,st_energy,st_zerorate,[thresm,thresz],noverlap)
%   label = myendpointdetect(frame,fs,st_energy,st_zerorate,[thresm,thresz],noverlap,pattern)
%   label = myendpointdetect(frame,fs,st_energy,st_zerorate,[thresm,thresz],noverlap,pattern,disp)
%   [label,endpoint,S1] = myendpointdetect(...)
%   [label,endpoint,S1.S2] = myendpointdetect(...)

%   Copyright (c) 2018 CHEN Tianyang
%   more info contact: tychen@whu.edu.cn

%% ������Ŀ���
narginchk(5,8);
nargoutchk(0,4);

%% ������ʼ��
%֡����֡��
[nframe,nwin] = size(frame);
%֡�ص�����
if nargin<6
    noverlap = round(nwin/2);
end
%�Ƿ���ʾ����
if nargin<7
    disp = false;
end
%֡��
nstride = nwin-noverlap;

%% ɸѡ��������ֵ��֡
threshm = thresh(1);
threshz = thresh(2);
indexm = st_energy >= threshm;
indexz = st_zerorate >= threshz;
if pattern == 1   
    label = indexm|indexz;  % �������(��������)
else
    label = indexm;         % ���������
end

%% Ѱ�Ҷ˵�
current = 0;
endpoint_index = [];
for i=1:nframe
    last = current;
    current = label(i);
    if (last==0) && (current==1) %����֡��ʼ
        start_index = i;
    elseif (last==1) && (current==0) %����֡����
        end_index = i-1;
        index = false(nframe,1);
        index(start_index:end_index) = 1;
        if ~any(index&indexm) %��������֡
            label(start_index:end_index) = 0;
        else
            endpoint_index = cat(1,endpoint_index,[start_index,end_index]);
        end
    elseif (i==nframe) && (current==1) %����֡����
        end_index = i;
        index = false(nframe,1);
        index(start_index:end_index) = 1;
        if ~any(index&indexm) %��������֡
            label(start_index:end_index) = 0;
        else
            endpoint_index = cat(1,endpoint_index,[start_index,end_index]);  
        end
    end
end
% ������֡��0
frame(~label,:) = 0;
% �źźϳ�
S1 = mydeframing(frame,noverlap);
% ������(������������)
signal_frame = frame;
signal_frame(~label,:) = [];
S2 = mydeframing(signal_frame,noverlap);

%% �˵�λ��
endpoint = zeros(size(endpoint_index));
endpoint(:,1) = (endpoint_index(:,1)-1)*nstride+1;
endpoint(:,2) = (endpoint_index(:,2)-1)*nstride+nwin;
% ---------- ���ض�Ӧ���¿��Լ������,����������ȴ���˵���
% syllable_len = endpoint(:,2)-endpoint(:,1);
% syllable_num = length(syllable_len);
% if syllable_num > 1
%     % ��ΪС�������1/3�������������
%     Thresh = round(1/3*max(syllable_len));
%     for i=1:syllable_num
%         if syllable_len(i) < Thresh     
%             endpoint(i,:)=0;
%         end
%     end
% end
% % endpoint ��ȫ0��ɾ��
% endpoint(all(endpoint==0,2),:) = [];
% ---------- ʿ��΢������Ŀ,������������������ --------------------

%% û�����������disp==true������źŲ���
if nargout==0 || disp
    nx = length(S1);
    t = (0:(nx-1))/fs;
    plot(t,S1);
    hold on;
    xlabel('ʱ��(s)');
    ylabel('����');
    title('��ȡ�������ź�ʱ����');
    for i=1:size(endpoint,1)
        x = (endpoint(i,1)-1)/fs;
        line(x,0,'Marker','.','MarkerSize',20,'Color',[1,0,0]);
        x = (endpoint(i,2)-1)/fs;
        line(x,0,'Marker','.','MarkerSize',20,'Color',[0,1,0]);
    end
    hold off;   
end

%% ���
switch nargout
    case 1
        varargout = {label};
    case 2
        varargout = {label,endpoint};
    case 3
        varargout = {label,endpoint,S1};
    case 4
        varargout = {label,endpoint,S1,S2};
end

end
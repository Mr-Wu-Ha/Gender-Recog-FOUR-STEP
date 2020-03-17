function [frame,E,M,Z,T] = mytimegram(x,fs,varargin)
%MYTIMEGRAM - short-time time domain freture
%
%   This MATLAB function returns [E,M,Z], the short-time time domain freture of the input
%   signal vector x.
%
%   [frame,E,M,Z,T] = mytimegram(x,fs)
%   [frame,E,M,Z,T] = mytimegram(x,fs,nwin)
%   [frame,E,M,Z,T] = mytimegram(x,fs,nwin,noverlap)
%   [frame,E,M,Z,T] = mytimegram(x,fs,nwin,noverlap,[threshe,threshm,threshz])
%   [frame,E,M,Z,T] = mytimegram(x,fs,nwin,noverlap,[threshe,threshm,threshz],disp)
%   [frame,E,M,Z,T] = myspectrogram(...,Property)
%   myspectrogram(...)

%   Property��{'truncation'},'padding'  

%������Ŀ���
narginchk(2,7);

%��xתΪ������
if isvector(x)==1
    x = x(:);
    nx = length(x);
else
    error('�������''x''����Ϊ1ά����');
end

%�ضϡ�����ѡ��
endprocess = 'truncation';
if (nargin > 2 && ischar(varargin{end})) && any(strcmpi(varargin{end},{'truncation','padding'}))
    endprocess = varargin{end};
    varargin(end)=[];
end

%��ȡʣ�����������Ŀ
narg = numel(varargin);
%�������
nwin = 160;     %20ms (fs=8000Hz)
noverlap = round(nwin/2);
disp = true;
thresh = [0,0,0];
%��ȡ�������ֵ
switch narg
    case 0
    case 1
        nwin = varargin{:};      
    case 2
        [nwin,noverlap] = varargin{:};
    case 3
        [nwin,noverlap,thresh] = varargin{:};
    case 4
        [nwin,noverlap,thresh,disp] = varargin{:};
    otherwise
        error('�����������');
end

%%
%�������
%֡�ص�����noverlap
if noverlap >= nwin
    error('''noverlap''��ֵ����С��''window''�ĳ���');
end

%��ֵthresh
threshe = 0;
threshm = 0;
threshz = 0;
if length(thresh)==3
    threshe = thresh(1);
    threshm = thresh(2);
    threshz = thresh(3);
end

%֡��nstride
nstride=nwin-noverlap; 
%�ź�x���ֳܷ�����֡�����ýضϴ�ʩ 
if strcmpi(endprocess,'truncation')
    %֡��
    nframe=fix((nx-noverlap)/nstride);   
%�ź�x���ֳܷ�����֡�����ò����ʩ   
else
    %֡��
    nframe=ceil((nx-noverlap)/nstride); 
    npadding=nframe*nstride+noverlap-nx;
    %ĩβ����
    x=[x;zeros(npadding,1)];  
end

%%
%��֡
frame=zeros(nwin,nframe);
for i=1:nframe
    start_index=(i-1)*nstride+1;
    end_index=start_index+nwin-1;
    frame(:,i)=x(start_index:end_index);
    %ȥֱ������
    frame(:,i) = frame(:,i)-median(frame(:,i));
end

%%
%����ʱ������
%��ʱ����
E = zeros(1,nframe);
for i=1:nframe
    E(i) = sum((frame(:,i)).^2);
end

%��ʱƽ������
M = zeros(1,nframe);
for i=1:nframe
    M(i) = sum(abs(frame(:,i)));
end

%��ʱ������
Z = zeros(1,nframe);
for i=1:nframe
    Z(i) = 0.5*sum(abs(sign(frame(2:nwin,i))-sign(frame(1:(nwin-1),i))));
end

%����ÿһ֡���м��ʱ��(T)
T=zeros(1,nframe);
for i=1:nframe
    start_time=(i-1)*nstride;
    T(i)=start_time+nwin/2;
end
T=T/fs;

%û�����������disp==true������źŲ���
if nargout==0 || disp
    plot(T,E,'r',T,M,'g',T,Z,'b');
    strlegend = {'��ʱ����','��ʱƽ������','��ʱ������'};
    hold on;
    if threshe~=0
        ThE = T;
        ThE(:) = threshe;
        plot(T,ThE,'r','LineWidth',2);
        strlegend = cat(2,strlegend,'��ʱ������ֵ');
    end
    if threshm~=0
        ThM = T;
        ThM(:) = threshm;
        plot(T,ThM,'g','LineWidth',2);
        strlegend = cat(2,strlegend,'��ʱƽ��������ֵ');
    end  
    if threshz~=0
        ThZ = T;
        ThZ(:) = threshz;
        plot(T,ThZ,'b','LineWidth',2);
        strlegend = cat(2,strlegend,'��ʱ��������ֵ');
    end
    hold off;
    legend(strlegend);
    xlabel('ʱ��(s)');
    ylabel('����');
    title('ʱ����');
end





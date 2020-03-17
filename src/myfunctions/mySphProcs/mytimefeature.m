function [frame,st_energy,st_zerorate,T_series] = mytimefeature(x,fs,varargin)
%MYTIMEFEATURE - short-time time domain features of a sector of voice
%
%   This MATLAB function returns [frame,st_energy,st_zerorate], the short-time 
%   energy and zero rate of the input signal vector x.
%
%   [frame,st_energy,st_zerorate,T_series] = mytimefeature(x,fs)
%   [frame,st_energy,st_zerorate,T_series] = mytimefeature(x,fs,nwin)
%   [frame,st_energy,st_zerorate,T_series] = mytimefeature(x,fs,nwin,noverlap)
%   [frame,st_energy,st_zerorate,T_series] = mytimefeature(x,fs,nwin,noverlap,[threshm,threshz])
%   [frame,st_energy,st_zerorate,T_series] = mytimefeature(x,fs,nwin,noverlap,[threshm,threshz],disp)
%   [frame,st_energy,st_zerorate,T_series] = mytimefeature(...,option)
%   mytimefeature(...)

%   option��{'truncation'},'padding'  

%% ������Ŀ���
narginchk(2,7);
nargoutchk(0,4);

%% ������ȡ
%�ضϡ�����ѡ��
option = 'truncation';
if (nargin > 2 && ischar(varargin{end})) && any(strcmpi(varargin{end},{'truncation','padding'}))
    option = varargin{end};
    varargin(end)=[];
end
%��ȡʣ�����������Ŀ
narg = numel(varargin);
%�������
ntime = 20;     % 20ms
nwin = fs*ntime/1000;
noverlap = round(nwin/2);
disp = false;
thresh = [0,0];
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
        error('�����������\n');
end

%% ����ֵ���
%��xתΪ������
if isvector(x)==1
    x = x(:);
else
    error('�������x����Ϊ1ά����\n');
end
%֡�ص�����noverlap
if noverlap >= nwin
    error('����noverlap��ֵ����С�ڲ���window����ֵ\n');
end
%��ֵthresh
threshm = 0;       % ��ʱƽ��������ֵ
threshz = 0;       % ��ʱ��������ֵ
if length(thresh)==2
    threshm = thresh(1);
    threshz = thresh(2);
end

%% ��֡
frame = myvectorframing(x,nwin,noverlap,option);
nframe = size(frame,1);
for i=1:nframe
    %ȥֱ������
    frame(i,:) = frame(i,:)-mean(frame(i,:));
end

%% ����ʱ������
%��ʱƽ������(��ʾ����)
st_energy = zeros(nframe,1);
for i=1:nframe
    st_energy(i) = sum(abs(frame(i,:)));
end
%��ʱ������
st_zerorate = zeros(nframe,1);
for i=1:nframe
    st_zerorate(i) = 0.5*sum(abs(sign(frame(i,2:nwin))-sign(frame(i,1:(nwin-1)))));
end

%% ����ÿһ֡���м��ʱ��(T)
nstride = nwin-noverlap;
T_series=zeros(nframe,1);
for i=1:nframe
    start_time=(i-1)*nstride;
    T_series(i)=start_time+nwin/2;
end
T_series=T_series/fs;

%% û�����������disp==true������źŲ���
if nargout==0 || disp
    figure;
    plot(T_series,st_energy,'r',T_series,st_zerorate,'g');
    strlegend = {'��ʱƽ������','��ʱ������'};
    hold on;
    if threshm~=0
        ThM = T_series;
        ThM(:) = threshm;
        plot(T_series,ThM,'r','LineWidth',2);
        strlegend = cat(2,strlegend,'��ʱƽ��������ֵ');
    end  
    if threshz~=0
        ThZ = T_series;
        ThZ(:) = threshz;
        plot(T_series,ThZ,'g','LineWidth',2);
        strlegend = cat(2,strlegend,'��ʱ��������ֵ');
    end
    hold off;
    legend(strlegend);
    xlabel('ʱ��(s)');
    ylabel('����');
    title('ʱ����');
end

end
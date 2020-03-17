function varargout = mygetspeech(frame,fs,M,Z,threshm,threshz,noverlap,disp)
%GETSPEECH - extract speech signal by the time domain feature
%
%   S = getspeech(frame,fs,M,Z,thresm,thresz)
%   S = getspeech(frame,fs,M,Z,thresm,thresz,noverlap)
%   S = getspeech(frame,fs,M,Z,thresm,thresz,noverlap,disp)
%   [S,startp,endp] = getspeech(...)

%������Ŀ���
narginchk(6,8);
nargoutchk(0,3);

%%
%������ʼ��
%֡����֡��
[nwin,nframe] = size(frame);
%֡�ص�����
if nargin<7
    noverlap = round(nwin/2);
end
%�Ƿ���ʾ����
if nargin<8
    disp = true;
end
%֡��
nstride=nwin-noverlap;
%�źų���
nx = nframe*nstride+noverlap;
S = zeros(nx,1);

%%
%ɸѡ��С����ֵ��֡
indexm = M < threshm;
indexz = Z < threshz;
%С����ֵ��֡��Ϊ0
frame(:,indexm&indexz) = 0;

%%
%�źźϳ�
startp = [];
endp = [];
isstart = false;
for i=1:nframe
    start_index = (i-1)*nstride+1;
    mid_index =  start_index+nstride-1;
    end_index = start_index+nwin-1;
    %����֡��ֵ�Ÿ���S
    if frame(1,i)~=0
        S(start_index:end_index) = frame(:,i);
        %��������ʼ��
        if ~isstart
            startp = [startp,start_index];
            isstart = true;
        end
        %ĩβΪ���������һ����ֹ��
        if i==nframe
            endp = [endp,end_index];
        end
    else
        %��������ֹ��
        if isstart
            endp = [endp,mid_index];
            isstart = false;
        end
    end
end

%%
%û�����������disp==true������źŲ���
if nargout==0 || disp
     t = (0:(nx-1))/fs;
    plot(t,S);
    hold on;
    xlabel('ʱ��(s)');
    ylabel('����');
    title('��ȡ�������ź�ʱ����');
    for i=1:length(startp)
        x = (startp(i)-1)/fs;
        line(x,0,'Marker','.','MarkerSize',20,'Color',[1,0,0]);
        x = (endp(i)-1)/fs;
        line(x,0,'Marker','.','MarkerSize',20,'Color',[0,1,0]);
    end
    hold off;   
end

switch nargout
    case 1
        varargout = {S};
    case 2
        varargout = {S,startp};
    case 3
        varargout = {S,startp,endp};
end



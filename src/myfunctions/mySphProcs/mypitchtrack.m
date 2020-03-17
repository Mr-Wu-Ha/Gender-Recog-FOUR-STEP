%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              ����һ                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function varargout = mypitchtrack(varargin)
% %PITCHTRACK - Pitch track by cepstrum analysis
% %
% %   This MATLAB function finds the pitch of the signal frames by 
% %   cepstrum analysis.
% %
% %   [period,T] = pitchtrack(frame,fs)
% %   [period,T] = pitchtrack(x,fs,nwin)
% 
% %% ��������
% % ��������Ŀ
% narginchk(2,3);
% nargoutchk(1,2);
% 
% % ��ȡ�������ֵ
% % ��ȡ��һ���������ֵ
% arg1 = varargin{1};
% if isvector(arg1)   % arg1������x�����뻹û�з�֡
%     [x,fs,nwin] = varargin{:};
%     frame = framing(x,nwin,0,'truncation');
% else                % arg1�Ǿ���frame�������Ѿ���֡
%     [frame,fs] = varargin{:};
% end
% [nwin,nframe] = size(frame);
% 
% %% ���㵹��
% nfft=max(256,power(2,ceil(log2(nwin))));  % fft�任����
% cep=zeros(nfft,nframe);
% for i=1:nframe
%     cep(:,i)=myrceps(frame(:,i));
% end
% 
% %% ����������ֵ(�����ж�)
% E=sum(frame.^2);        %�������
% % magnitude = sum(abs(frame));        % ÿ֡����
% % threshmedian = median(magnitude);   % ��ֵ
% % threshmean = mean(magnitude);       % ��ֵ
% % if threshmean>1.5*threshmedian      % �����ֵ����ֵ�ǳ��ӽ�������Ϊ�󲿷־�Ϊ�����źţ���ֵ��Ϊ0
% %     threshe = threshmedian;
% % else
% %     threshe = 0;
% % end
% 
% %% ��ȡ����������������� ->frame_period
% % ���׵ĺ�����������ʱ��t���˵Ļ�����2-20ms/50-500Hz
% ncep_start = round(0.002*fs+1);                  % ���׿�ʼ��
% ncep_end = min(round(0.02*fs+1),round(nwin/2));  % ���׽�����
% cep_max=zeros(1,nframe);                         % ÿһ֡�������ֵ
% frame_period = zeros(1,nframe);                  % ÿһ֡�Ļ�������(ÿһ֡�������ֵ��)
% % ����һ��������������ֵ�ͷ���ж��ǲ��Ǵ�����
% % ���η�����(����/����)
% if mean(E)<0.5 && var(E)<0.01        % 0.5��0.01���Ǿ�����ֵ   
%     for i=1:nframe
%         frame_period(i)=0;           % �����ǻ���Ƶ�ʣ���ÿһ֡��ƵΪ0
%     end
% % ���δ���������ֵΪ0
% elseif mean(E)>=2 && var(E)<1        % 2��1Ҳ���Ǿ�����ֵ                           
%     for i=1:nframe                   % ������һ֡���������͵��������Է�ֵ
%         [cep_max(i),frame_period(i)]=max(cep(ncep_start:ncep_end,i));
%     end
% % ������V/U/S
% else
%     threshe=median(E);      % ��������������ȡ��ֵΪ��ֵ
%     for i=1:nframe
%         if E(i)<threshe              % ������������������(�ܿ����Ǿ���)
%             frame_period(i)=0;
%         else
%             [cep_max(i),frame_period(i)]=max(cep(ncep_start:ncep_end,i));
%             threshild=4*abs(mean(cep(ncep_start:ncep_end,i)));
%             if cep_max(i)<threshild   % ����û�����Եķ�ֵ����������(�ܿ���������)
%                 frame_period(i)=0;
%             end
%         end
%     end
% end
% % ת��ʱ��Ϊ��λ
% frame_period=(frame_period+ncep_start-2)/fs;    %ע�⣡������-2����-1
% for i=1:nframe
%     if frame_period(1,i)<0.002        %(1/8000=0.000125),�������µĶ���0.001875
%         frame_period(1,i)=0;
%     end
% end
% 
% %% ����ÿһ֡���м��ʱ��(T)
% T = zeros(1,nframe);
% for i=1:nframe
%     start_time = (i-1)*nwin;
%     T(i) = start_time+nwin/2;
% end
% T = T/fs;
% 
% %% ����������
% if nargout==1
%     varargout = {frame_period};
% else
%     varargout = {frame_period,T};
% end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              ������                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = mypitchtrack(varargin)
%PITCHTRACK - Pitch track by cepstrum analysis
%
%   This MATLAB function finds the pitch of the signal frames by 
%   cepstrum analysis.
%
%   [period,pitch,T] = pitchtrack(frame,fs)
%   [period,pitch,T] = pitchtrack(x,fs,nwin)

%% ��������
% ��������Ŀ
narginchk(2,3);
nargoutchk(1,3);

% ��ȡ�������ֵ
% ��ȡ��һ���������ֵ
arg1 = varargin{1};
if isvector(arg1)   % arg1������x
    [x,fs,nwin] = varargin{:};
    frame = myvectorframing(x,nwin,0,'truncation');
else                % arg1�Ǿ���frame
    [frame,fs] = varargin{:};
end
[nframe,~] = size(frame);

%% ����������ֵ
magnitude = sum(abs(frame),2);      % ÿ֡����
threshmedian = median(magnitude);   % ��ֵ
threshmean = mean(magnitude);       % ��ֵ
if threshmean>1.5*threshmedian      % �����ֵ����ֵ�ǳ��ӽ�������Ϊ�󲿷־�Ϊ�����źţ���ֵ��Ϊ0
    threshe = threshmedian;
else
    threshe = 0;
end

%% �����������(����)
%�����˵Ļ������ڷ�Χ2~20ms(50~500Hz)
tstart = round(0.002*fs+1);
tend = min(round(0.02*fs+1),round(nwin/2));
period = zeros(1,nframe);
for i=1:nframe
    if magnitude(i)>=threshe
        c = myrceps(frame(i,:));        % ����ĳһ֡�ĵ���
        [maximum,maxpos] = max(c(tstart:tend));
        threshold = 4*mean(abs(c(tstart:tend)));
        if maximum>=threshold       %����
            period(i) = (maxpos+tstart-2)/fs;
        else                        %��������
            period(i) = 0;
        end
    else                            %��������
        period(i) = 0;
    end
end

%% ����һ��������ƽ������Ƶ�� pitch 
pitchs = 1./period;           
pitchs(pitchs==Inf) = [];
Pitch.mean = mean(pitchs);
Pitch.min = min(pitchs);
Pitch.max = max(pitchs);

%% ����ÿһ֡���м��ʱ��(T)
T = zeros(1,nframe);
for i=1:nframe
    start_time = (i-1)*nwin;
    T(i) = start_time+nwin/2;
end
T = T/fs;

%% ���
switch nargout
    case 1
        varargout = {period};
    case 2
        varargout = {period,Pitch};
    case 3
        varargout = {period,Pitch,T};
end

end
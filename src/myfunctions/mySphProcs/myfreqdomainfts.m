function freqfts = myfreqdomainfts(x_voiced,fs,nwin,noverlap)

% ��֡
frame = myvectorframing(x_voiced,nwin,noverlap,'truncation');
[nframe,framelen] = size(frame);
% ��֡���� Ƶ�� �� ����
nfft=max(256,power(2,ceil(log2(framelen))));
amp = zeros(nframe,nfft);
c = zeros(nframe,nfft);
for i=1:nframe
    window = (hamming(framelen))';
    single_frame = frame(i,:).*window;
    amp(i,:) = abs(fft(single_frame,nfft));
    logamp = log(amp(i,:)+eps);     % ��ֹamp==0
    c(i,:) = real(ifft(logamp));
end

%% 
% figure;
% subplot(2,2,1);plot(frame(1,:));xlabel('sample');ylabel('amptitude');title('ĳһ֡����');
% subplot(2,2,2);plot(single_frame);xlabel('sample');ylabel('amptitude');title('��֡�����Ӵ���');
% subplot(2,2,3);plot(amp(1,:));xlabel('sample');ylabel('amptitude');title('��֡������Ƶ��');
% subplot(2,2,4);plot(c(1,:));xlabel('sample');ylabel('amptitude');title('��֡��������');

%% ����
amp = amp(:,1:nfft/2);      % ��ȡ�ԳƵ�һ����
amp = amp./repmat(sum(amp,2),1,nfft/2);     % map�����й�һ��
MF = zeros(nframe,0);
SE = zeros(nframe,0);
for i=1:nframe
    mf = 0;
    se = 0;
    for j=1:nfft/2
       mf = mf + j*amp(i,j);    
       se = se - amp(i,j)*(log(amp(i,j))/log(2));   
    end
    MF(i) = mf/nfft*fs;         % ĳһ֡�ļ�Ȩƽ��Ƶ��
    SE(i) = se/(nfft/2);        % ĳһ֡������
end
% 1 �ö�������Ƶ�ʾ�ֵ(kHz)
fmean = mean(MF)/1000;
% meanfrenqucy = meanfreq(x_voiced,fs);
% 2 �ö�������Ƶ�ʱ�׼��(kHz)
fstd = std(MF)/1000;
% 3 �ö�������Ƶ����ֵ(kHz)
fmid = median(MF)/1000;
% medianfrenqucy = medfreq(x_voiced,fs);
% 4 �ö�������Ƶ��Q25(kHz)
fQ25 = quantile(MF,0.25)/1000;
% 5 �ö�������Ƶ��Q75(kHz)
fQ75 = quantile(MF,0.75)/1000;
% 6 �ö�������Ƶ���ķ�λ��� (kHz)
fiqr = iqr(MF)/1000;
% 7 �ö�������бƫ
skew = skewness(MF);
% 8 �ö������ķ��
kurt = kurtosis(MF);
% 9 �ö�������ƽ������
spent = mean(SE);
% 10 �ö����������ع⻬�� (���С�����ˣ��������ױ�Ϊ0������������)
% sfm = prod(SE)^(1/nframe)/mean(SE);
% 11 �ö�������Ƶ�ʵ�����
nstep = 16;
stats = mynumstatistic(mydiscretization(MF,nstep));
[~,pos] = max(stats(:,2));
mode = max(MF)*pos/nstep/1000;
% ��Ƶ(3 fts)(kHz)
[~,Pitch,~] = mypitchtrack(x_voiced,fs,nwin);
% 12 �ö�������ƽ����Ƶ
pitchmean = Pitch.mean/1000;
% 13 �ö�����������Ƶ
pitchmax = Pitch.max/1000;
% 14 �ö���������С��Ƶ
pitchmin = Pitch.min/1000;

%% ���
% ���Ϊһ��������
freqfts = [fmean fstd fmid fQ25 fQ75 fiqr skew kurt spent mode ...
    pitchmean pitchmax pitchmin];

end
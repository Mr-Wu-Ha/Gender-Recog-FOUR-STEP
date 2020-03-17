function feature = myfeature(x,fs)
%MYFEATURE - Extract features of the signal x
%
%   feature = myfeature(x,fs)

%% ���ȹ�һ��
x = x/max(abs(x));
%% �ز���
if fs ~=8000
    x = resample(x,8000,fs);
    fs = 8000;
end
%% Ԥ����
x = filter([1,-0.9375],1,x);

%% Ԥ���� - ��ȡ����֡����ȥ����֡
ntime = 20;     % 20ms
nwin = fs*ntime/1000;
noverlap = round(nwin/2);
[frameA,st_energy,st_zerorate,~] = mytimefeature(x,fs,nwin,noverlap,[0,0]);
[~,~,~,x_voiced] = myendpointdetect(frameA,fs,st_energy,st_zerorate,[mean(st_energy),median(st_zerorate)],noverlap,0,0);
x_voiced = x_voiced/max(abs(x_voiced));

%% ��������ͼ
% t1 = (0:length(x)-1)/fs;
% t2 = (0:length(x_voiced)-1)/fs;
% figure;
% subplot(1,2,1);plot(t1,x);xlabel('time/s');ylabel('amp');title('Original speech');
% subplot(1,2,2);plot(t2,x_voiced);xlabel('time/s');ylabel('amp');title('Voiced speech');

%% ��ȡ����
% Ƶ������
freqfts = myfreqdomainfts(x_voiced,fs,nwin,noverlap);
freqfts = freqfts(:)';      % ת��Ϊ������
% MFCC����
[mfcc,~,~] = mymfcc(x_voiced,fs);
% ����ÿһ��������mfcc������һ������(֡��*mfcc����)�����������Ҫ�� freqfts 
% ����ʹ�ã��ͱ��뽫��ת��Ϊ����(1*mfcc����)
% ���� dmfcc ���ܼ򵥵�ƽ�����£���Ϊdmfcc����mfcc�Ĳ�֣�
% ��ƽ�� = (��һ֡��mfcc-���һ֡��mfcc)/֡��
% ���²���Ӧ�������˵�:
meanmfcc = mean(mfcc);
nf = size(mfcc,1);
meandmfcc = mean( mfcc(1:round(nf/2),:) )-mean( mfcc(round(nf/2)+1:nf,:) );
dmmfcc = [meanmfcc meandmfcc];
%% �������
feature = [freqfts dmmfcc];         % ���Ϊһ��������
% feature = freqfts;
end
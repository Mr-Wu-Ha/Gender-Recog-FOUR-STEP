function voiced = mygetvoiced(x,fs)
%GETVOICED - Get voiced sound of a certain voice segment 
%
%   voiced = getvoiced(x,fs)

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
[~,~,~,voiced] = myendpointdetect(frameA,fs,st_energy,st_zerorate,[mean(st_energy),median(st_zerorate)],noverlap,0,0);
voiced = voiced/max(abs(voiced));

end
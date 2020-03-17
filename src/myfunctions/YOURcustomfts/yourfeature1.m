function fts1 = yourfeature1(voiced,fs)
%MYFEATURE1 - Extract YOURCUSTOM feature of the signal x
%
%   fts1 = myfeature1(x,fs)

% ��һ��д�õĴ��룬��ע�ͣ��⿪������

%% 
% ��֡����
ntime = 20;     % 20ms
nwin = fs*ntime/1000;
noverlap = round(nwin/2);
frame = myvectorframing(x_voiced,nwin,noverlap,'truncation');



fts1 = fts1(:)';
end
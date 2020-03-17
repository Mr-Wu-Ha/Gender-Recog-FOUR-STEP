function c = myrceps(single_frame)
% MYRCEPS - Calculate the cepstrum
%
%   c = myrceps(x,nfft)

%% ����Ԥ��
if ~isvector(single_frame)
    error('Error! Input parameter "single_frame" should be a vector\n');
end
single_frame = single_frame(:);
%% ����
% �Ӵ�
window = hamming(length(single_frame));
single_frame = single_frame.*window;
% FFT �õ�Ƶ��
nfft=max(256,power(2,ceil(log2(length(single_frame)))));
amp = abs(fft(single_frame,nfft));
% �õ�����Ƶ��
logamp = log(amp+eps);     % ��ֹamp==0
% ���㵹��
c = real(ifft(logamp));

end
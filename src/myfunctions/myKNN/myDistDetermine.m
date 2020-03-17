function Results = myDistDetermine(traindata,trainlabel,valdata)
% ��ֻ�ǳ��壬ֻ�ܴ���2��������⣬ͨ����̫��Ժ��Ҹ�ʱ���������������£�
% Ӧ��ʵ�ֶ��������޶��������� Distance Dertermination ������

% ��ѵ����
class_num_train = mynumstatistic(trainlabel);
female_core = mean(traindata(1:class_num_train(1,2),:));        % ��һ��������
male_core = mean(traindata(class_num_train(1,2)+1:class_num_train(1,2)+class_num_train(2,2),:));    % ��һ��������

% ����ж���֤��
valnum = size(valdata,1);
dist = zeros(valnum,2);
predicted_label = zeros(valnum,1);
for i=1:valnum
    dist(i,1) = sum((valdata(i,:)-female_core).^2);
    dist(i,2) = sum((valdata(i,:)-male_core).^2);
    if dist(i,1)>=dist(i,2)
        predicted_label(i) = 2;     % �ж�Ϊ����
    else
        predicted_label(i) = 1;     % �ж�ΪŮ��
    end
end

% ������
DCtraincore = [female_core;male_core];
Results.DCtraincore = DCtraincore;
Results.predicted_label = predicted_label;
end
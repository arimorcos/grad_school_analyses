%%
neuron = 9;

figure;
hold on;
plot(completeTrace(neuron,:));
plot(c(neuron,:));
plot(deconvTrace(neuron,:));

%% get denoised

F = completeTrace(neuron,:);
% fTemp = F(F<median(F));
% noiseVal = mad([fTemp,max(fTemp)-fTemp],0);
noiseVal = 1.4826*mad(F,1);

[cTest,~,~,~,~,deconvTest] = ...
    constrained_foopsi(completeTrace(neuron,:),[],[],[],noiseVal);

%% get with different options
options.noise_range = [0.01 0.02];
[cTest,~,~,~,~,deconvTest] = ...
    constrained_foopsi(completeTrace(neuron,:),[],[],[],[],options);

%% plot two 

figure;
hold on;
plot(completeTrace(neuron,:));
plot(c(neuron,:));
plot(cTest);

%% get spike corrcoef
corrcoef(deconvTrace(neuron,:),deconvTest)
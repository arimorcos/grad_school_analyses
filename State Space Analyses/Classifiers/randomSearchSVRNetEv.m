gammaRange = [1e-6 1];
epsilonRange = [1e-6 1];
gammaOptions = linspace(gammaRange(1), gammaRange(2), 100);
epsilonOptions = linspace(epsilonRange(1), epsilonRange(2), 100);

trainInd = randsample(1:1692,850,1);

for i = 1:100
    
    %randomly generate parameters 
    epsilon(i) = epsilonOptions(randi([1 100]));
    gamma(i) = gammaOptions(randi([1 100]));
    
    [guess,mse,testClass,corrCoef] =...
        getSVMAccuracy(segTraces,realClass,...
        'svmType', 'e-SVR', 'C',2,'epsilon',epsilon(i),...
        'gamma',gamma(i),'kFold',1,...
        'trainind',[],'trainFrac',0.5);
    tempCorr = corrcoef(guess,testClass);
    netEvCorr(i) = tempCorr(1,2);
    
    dispProgress('%d/%d',i,i,100);
end
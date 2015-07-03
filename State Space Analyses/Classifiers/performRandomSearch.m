%get traces
[~,traces] = catBinnedTraces(imTrials);

%crop to near end bin
traces = traces(:,115,:);

%get sortOrder 
coeff = calculateTrialTrialVarCoefficient(imTrials);
[~,sortOrder] = sort(coeff,'descend');

%crop to bottom half of cells 
traces = traces(sortOrder(1:300),:,:);

%get leftTurns
leftTurns = getCellVals(imTrials,'result.leftTurn');

%get ranges
cRange = [0 8];
gammaRange = [1e-6 4];
cOptions = linspace(cRange(1), cRange(2), 100);
gammaOptions = linspace(gammaRange(1), gammaRange(2), 100);

%loop through and generate parameters 
nIter = 1000;
cParam = nan(nIter,1);
gamma = nan(nIter,1);
acc = nan(nIter,1);
for i = 1:nIter

    %randomly generate parameters 
    cParam(i) = cOptions(randi([1 100]));
    gamma(i) = gammaOptions(randi([1 100]));
    
    %get accuracy 
    acc(i) = getSVMAccuracy(traces,leftTurns,'cParam',cParam(i),'gamma',gamma(i));
    
    dispProgress('%d/%d',i,i,nIter);
end
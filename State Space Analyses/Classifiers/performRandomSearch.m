%get traces
% [~,traces] = catBinnedTraces(imTrials);

%crop to near end bin
traces = catBinnedDeconvTraces(imTrials);
traces = traces(:,5,:);
% traces = 100*traces;

%get train set 
% nTrials = size(traces,3);
% nTrain = round(0.5*nTrials);
% nTest = nTrials - nTrain;
% trainSet = randsample(nTrials,nTrain);
% testSet = setdiff(1:nTrials,trainSet);
% traces = traces(:,:,trainSet);
% 
% trainCorrect = correct(trainSet);


%get sortOrder 
% coeff = calculateTrialTrialVarCoefficient(imTrials);
% [~,sortOrder] = sort(coeff,'descend');

%crop to bottom half of cells 
% traces = traces(sortOrder(1:300),:,:);

%get leftTurns
% leftTurns = getCellVals(trials60,'result.leftTurn');
mazePatterns = getMazePatterns(imTrials);
% prevCorrect = getCellVals(imTrials,'result.prevCorrect');

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
    acc(i) = getSVMAccuracy(traces,prevTurn,'cParam',cParam(i),'gamma',gamma(i));
    
    dispProgress('%d/%d',i,i,nIter);
end
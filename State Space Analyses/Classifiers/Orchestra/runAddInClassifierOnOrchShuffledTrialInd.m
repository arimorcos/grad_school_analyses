function runAddInClassifierOnOrchShuffleTrialInd(dataCellPath)

%% preprocess
%add all files to path 
currDir = cd;
addpath(genpath(currDir));

%load dataCell
load(dataCellPath,'dataCell');

%add in previous result field
dataCell = addPrevTrialResult(dataCell);

%filter roiGroups
dataCell = filterROIGroups(dataCell,1);

imTrials = getTrials(dataCell,'maze.crutchTrial==0;imaging.imData==1');
imTrials = imTrials(~findTurnAroundTrials(imTrials));

%bin traces
imTrials = binFramesByYPos(imTrials,5);
imTrials = getTrials(imTrials,'maze.numLeft==0,6');


%% process

%get sortOrder 
coeff = calculateTrialTrialVarCoefficient(imTrials);
[~,sortOrder] = sort(coeff,'descend');

% get accuracy 
accuracy = getLeftRightAccuracyNeuronFallout(imTrials,sortOrder,false,10);

% perform shuffle
nShuffles = 100;
shuffleAccuracy = nan(size(accuracy,1),size(accuracy,2),nShuffles);
for shuffleInd = 1:nShuffles
    
    shuffleAccuracy(:,:,shuffleInd) = getLeftRightAccuracyNeuronFallout(imTrials,sortOrder,true,10);
    
end

%get file base and save
fileBase = sprintf('AM%d_%s',dataCell{1}.info.mouse,dataCell{1}.info.date);
save(sprintf('dataOut/%s_SVM_addIn_shuffledTrialArrangement',fileBase),'accuracy','shuffleAccuracy');
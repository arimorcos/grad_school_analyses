function runRunSpeedSVROnOrch(dataCellPath)

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

%get file base
fileBase = sprintf('AM%d_%s',dataCell{1}.info.mouse,dataCell{1}.info.date);

%get position classifier
allBinRunSpeed = classifyRunSpeedSVR(imTrials,'shouldShuffle',...
    true,'nShuffles',100,'posControl',false);
sinBinRunSpeed = classifyRunSpeedSVR(imTrials,'shouldShuffle',true,'nShuffles',100);
save(sprintf('%s_SVR_classifierOut_runSpeed',fileBase),'allBinRunSpeed','sinBinRunSpeed');
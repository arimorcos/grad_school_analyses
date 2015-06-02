function runTrialMatchedSVROnOrch(dataCellPath)

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
correctTrials = getTrials(imTrials,'result.correct==1');

%get file base
fileBase = sprintf('AM%d_%s',dataCell{1}.info.mouse,dataCell{1}.info.date);

%get classifiers for net evidence
groupClassifier = classifyNetEvGroupSegSVM(correctTrials,'shouldShuffle',true,'nShuffles',100,'classMode','netEv','trialMatch',true);
acrossClassifier = classifyNetEvAcrossSegSVM(correctTrials,'shouldshuffle',true,'nshuffles',100,'classMode','netEv','trialMatch',true);
save(sprintf('dataOut/%s_SVR_classifierOut_netEv_tMatch',fileBase),'acrossClassifier','groupClassifier');

%get classifiers for net evidence
groupClassifier = classifyNetEvGroupSegSVM(correctTrials,'shouldShuffle',true,'nShuffles',100,'classMode','numLeft','trialMatch',true);
acrossClassifier = classifyNetEvAcrossSegSVM(correctTrials,'shouldshuffle',true,'nshuffles',100,'classMode','numLeft','trialMatch',true);
save(sprintf('dataOut/%s_SVR_classifierOut_numLeft_tMatch',fileBase),'acrossClassifier','groupClassifier');

%get classifiers for net evidence
groupClassifier = classifyNetEvGroupSegSVM(correctTrials,'shouldShuffle',true,'nShuffles',100,'classMode','numRight','trialMatch',true);
acrossClassifier = classifyNetEvAcrossSegSVM(correctTrials,'shouldshuffle',true,'nshuffles',100,'classMode','numRight','trialMatch',true);
save(sprintf('dataOut/%s_SVR_classifierOut_numRight_tMatch',fileBase),'acrossClassifier','groupClassifier');
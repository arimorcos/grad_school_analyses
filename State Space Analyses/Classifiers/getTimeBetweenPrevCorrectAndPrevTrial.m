function timeDiff = getTimeBetweenPrevCorrectAndPrevTrial(mouse,date)
%getTimeBetweenPrevCorrectAndPrevTrial.m Calculates the time between the
%last signicicant previous correct classification and the last significant
%previous trial classification. 
%
%INPUTS
%mouse - mouse to measure 
%date - date 
%
%OUTPUTS
%timeDiff - structure containing the mean and std of the time in seconds 
%   between the two measurements 
%
%ASM 7/15

nTrue = 4;

%get svmPath
svmPath = 'D:\DATA\Analyzed Data\150602_SVMClassifiers';

%generate file names
prevCorrectFile = fullfile(svmPath,...
    sprintf('%s_%s_prevCorrect_allTrials_out.mat',mouse,date));
prevTurnFile = fullfile(svmPath,...
    sprintf('%s_%s_prevTurn_allTrials_out.mat',mouse,date));

%check that files exist
assert(exist(prevCorrectFile,'file')==2,'Previous correct file does not exist for mouse %s on date %s',mouse,date);
assert(exist(prevTurnFile,'file')==2,'Previous turn file does not exist for mouse %s on date %s',mouse,date);

%load files 
prevCorrectData = load(prevCorrectFile);
prevTurnData = load(prevTurnFile);

%find time last above shuffle for 2 consecutive bins. 
lastCorrectInd = getLastInd(prevCorrectData, nTrue);
lastTurnInd = getLastInd(prevTurnData, nTrue);

%load processed data 
imTrials = loadProcessed(mouse,date,{'imTrials'});

%get concatenated dataFrames
catDataFrames = catBinnedDataFrames(imTrials);

%get correct and turn times in matlab units
times = squeeze(catDataFrames(1,[lastCorrectInd,lastTurnInd],:));

%get difference in times 
dNumDiff = times(2,:) - times(1,:);

%convert to seconds 
timeDiff.allDiffs = dnum2secs(dNumDiff);
timeDiff.meanDiff = mean(timeDiff.allDiffs);
timeDiff.stdDiff = std(timeDiff.allDiffs);
timeDiff.semDiff = calcSEM(timeDiff.allDiffs);

end 

function ind = getLastInd(data,nTrue)

%calculate shuffle 95% conf bounds 
upperBound = prctile(data.shuffleAccuracy,97.5) + 0.5;

%find where is significant 
isSig = data.accuracy' >= upperBound;

%find consecutive fins 
ind = findLastConsecTrueString(isSig, nTrue);

end
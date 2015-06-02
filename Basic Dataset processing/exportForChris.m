function exportForChris(mouse,date,exportPath)

if nargin < 3 || isempty(exportPath)
    exportPath = 'Z:\HarveyLab\For Chris\ari\Datasets';
end

%load behavior day
dataCell = loadBehaviorData(mouse,date);

%limit to imTrials
imTrials = getTrials(dataCell,'imaging.imData==1;maze.crutchTrial==0');

%bin
imTrials = binFramesByYPos(imTrials,5);

%get binned traces
[~,traces] = catBinnedTraces(imTrials);

%get size 
[nNeurons, nBins, nTrials] = size(traces);

%get yPosBins
yPosBins = imTrials{1}.imaging.yPosBins;

%get segRange
segRanges = 0:80:480;

%get maze patterns
mazePatterns = getMazePatterns(imTrials);

%get net evidence
netEvidence = getNetEvidence(imTrials);

%get left turn 
leftTurn = getCellVals(imTrials,'result.leftTurn');

%get correct
trialCorrect = getCellVals(imTrials,'result.correct');

%save 
savePath = fullfile(exportPath,sprintf('%s_%s.mat',mouse,date));
save(savePath,'nNeurons','nBins','nTrials','yPosBins','segRanges',...
    'mazePatterns','netEvidence','leftTurn','trialCorrect','traces');
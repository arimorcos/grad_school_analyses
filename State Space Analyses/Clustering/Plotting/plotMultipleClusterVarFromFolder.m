function handles = plotMultipleClusterVarFromFolder(folder,fileStr)
%plotMultipleClusterVarFromFolder.m Plots multiple delta seg offset
%significance from folder
%
%INPUTS 
%folder - path to folder 
%fileStr - string to match files to 
%
%OUTPUTS
%handles - structure of handles 
%
%ASM 4/15
nEpoch = 10;
pointLabels = {'Maze Start','Segment 1','Segment 2','Segment 3','Segment 4',...
    'Segment 5','Segment 6','Early Delay','Late Delay','Turn'};

%get list of files in folder 
[allNames, ~, ~, ~, isDirs] = dir2cell(folder);
files = allNames(~isDirs);

%match string 
matchFiles = files(~cellfun(@isempty,regexp(files,fileStr)));

%loop through each file and create array 
fracLeft = nan(length(matchFiles),nEpoch);
fracRight = nan(length(matchFiles),nEpoch);
for fileInd = 1:length(matchFiles)
    currFileData = load(fullfile(folder,matchFiles{fileInd}));
    fracLeft(fileInd,:) = currFileData.out.fracLeft;
    fracRight(fileInd,:) = currFileData.out.fracRight;
end

%nFiles
nFiles = length(matchFiles);

figH = figure;
axH = axes;

%hold
hold(axH,'on');

%loop through and plot
xVals = 1:nEpoch;
errLeft = errorbar(xVals,mean(fracLeft),calcSEM(fracLeft));
errRight = errorbar(xVals,mean(fracRight),calcSEM(fracRight));

%customize 
errLeft.Marker = 'o';
errLeft.MarkerFaceColor = errLeft.Color;
errRight.Marker = 'o';
errRight.MarkerFaceColor = errRight.Color;

%label
axH.XTick = xVals;
axH.XTickLabel = pointLabels;
axH.XTickLabelRotation = -45;
axH.YLabel.String = 'Fraction of clusters visited';

%limits
axH.YLim = [0 1];
axH.XLim = [0.5 nEpoch+0.5];

%beautify
beautifyPlot(figH,axH);

%add legend
legend([errLeft, errRight],{'Left 6-0 trials','Right 0-6 trials'},...
    'Location','Best');





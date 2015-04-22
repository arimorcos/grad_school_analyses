function clusterInfo = plotMeanMazePattern(dataCell,clusters)

%get maze pattern
mazePattern = getMazePatterns(dataCell);

%get nClusters
uniqueClusters = unique(clusters);
nClusters = length(uniqueClusters);

%get leftTurns and correct
leftTurn = getCellVals(dataCell,'result.leftTurn');
correct = getCellVals(dataCell,'result.correct');
prevTurn = getCellVals(dataCell,'result.prevTurn');

%loop through each cluster
meanMazePattern = nan(nClusters,size(mazePattern,2));
fracLeft = nan(nClusters,1);
fracCorrect = nan(nClusters,1);
nTrials = nan(nClusters,1);
for clusterInd = 1:nClusters
    meanMazePattern(clusterInd,:) = mean(mazePattern(clusters==uniqueClusters(clusterInd),:));
    fracLeft(clusterInd) = mean(leftTurn(clusters==uniqueClusters(clusterInd)));
    fracCorrect(clusterInd) = mean(correct(clusters==uniqueClusters(clusterInd)));
    prevTurn(clusterInd) = mean(prevTurn(clusters==uniqueClusters(clusterInd)));
    nTrials(clusterInd) = sum(clusters==uniqueClusters(clusterInd));
end

%sort meanMazePattern by sum
sumPattern = sum(meanMazePattern,2);
[~,sortOrder] = sort(sumPattern);
meanMazePattern = meanMazePattern(sortOrder,:);
fracLeft = fracLeft(sortOrder);
fracCorrect = fracCorrect(sortOrder);
prevTurn = prevTurn(sortOrder)';
nTrials = nTrials(sortOrder);

%create table 
clusterInfo = table(meanMazePattern,fracLeft,fracCorrect,prevTurn,nTrials);
if nargout > 0 
    return;
end

%create figure 
figure; 
axH = axes;
hold(axH,'on');

%get text positions
textY = linspace(0,1,nClusters+3);
textY = textY(2:end-1);

%loop through and plot 
for clusterInd = 1:nClusters
    %mean maze pattern 
    textH = text(0,textY(clusterInd),num2str(meanMazePattern(clusterInd,:),'%.2f       '));
    textH.FontSize = 20;
    
    %fracLeft 
    textH = text(0.45,textY(clusterInd),num2str(fracLeft(clusterInd),'%.2f      '));
    textH.FontSize = 20;
    
    %fracCorrect
    textH = text(0.6,textY(clusterInd),num2str(fracCorrect(clusterInd),'%.2f      '));
    textH.FontSize = 20;
    
    %prevTurn 
    textH = text(0.75,textY(clusterInd),num2str(prevTurn(clusterInd),'%.2f      '));
    textH.FontSize = 20;
    
    %nTrials
    textH = text(0.9,textY(clusterInd),num2str(nTrials(clusterInd),'%02d      '));
    textH.FontSize = 20;
end

%plot labels
textH = text(0.125,textY(end),'Mean Maze Pattern');
textH.FontSize = 20;
textH.FontWeight = 'Bold';

textH = text(0.4,textY(end),'Frac Left');
textH.FontSize = 20;
textH.FontWeight = 'Bold';


textH = text(0.55,textY(end),'Frac Correct');
textH.FontSize = 20;
textH.FontWeight = 'Bold';

textH = text(0.7,textY(end),'Prev Turn');
textH.FontSize = 20;
textH.FontWeight = 'Bold';

textH = text(0.85,textY(end),'# Trials');
textH.FontSize = 20;
textH.FontWeight = 'Bold';

%set axes properties
axH.YTick = [];
axH.XTick = [];
function transMat = showCompleteTransitionMatrix(dataCell,clusters,colorBy)
%showCompleteTransitionMatrix.m Plots a transition matrix of the complete
%graph defined in the first cell of dataCell
%
%INPUTS
%dataCell - dataCell containing clustered data
%clusters - nPoints x 1 array of cluster identities
%colorBy - variable to color by
%
%ASM 4/15

%% initialize and create transition matrix

%get nFrames
nFrames = length(clusters);

%get unique clusters
uniqueClusters = unique(clusters);
nClusters = length(uniqueClusters);

%remap clusters to 1:nClusters
for clusterInd = 1:nClusters
    clusters(clusters == uniqueClusters(clusterInd)) = clusterInd;
end

%create transition matrix
transMat = zeros(nClusters);
for frameInd = 2:nFrames
    transMat(clusters(frameInd-1),clusters(frameInd)) = ...
        transMat(clusters(frameInd-1),clusters(frameInd)) + 1; %increment transition
end
transMat = transMat/nFrames;
transMat = mat2gray(transMat);
transMat = roundtowardvec(transMat,0:0.05:1);

%% create transition matrix document

%get clusterDataFrames
clusterDataFrames = dataCell{1}.imaging.clusterDataFrames;
clusterTrialIDs = dataCell{1}.imaging.clusterTrialIDs;

%colorBy
nColorBins = 50;
switch colorBy
    case 'yposition'
        %calculate mean yposition
        clusterVal = nan(nClusters,1);
        for clusterInd = 1:nClusters
            clusterVal(clusterInd) = mean(clusterDataFrames(3,clusters==clusterInd));
        end
        colorPossibilities = parula(nColorBins);
        colors = getColorByMap(clusterVal,nColorBins,nClusters,colorPossibilities);
    case 'iti'
        %calculate probability of iti
        clusterVal = nan(nClusters,1);
        for clusterInd = 1:nClusters
            clusterVal(clusterInd) = 1-mean(clusterTrialIDs(2,clusters==clusterInd));
        end
        colorPossibilities = flipud(gray(nColorBins));
        colors = getColorByMap(clusterVal,nColorBins,nClusters,colorPossibilities);
    case 'viewAngle'
        %calculate mean yposition
        clusterVal = nan(nClusters,1);
        for clusterInd = 1:nClusters
            clusterVal(clusterInd) = rad2deg(mean(clusterDataFrames(4,clusters==clusterInd)))-90;
        end
        colorPossibilities = redblue(nColorBins);
        colors = getColorByMap(clusterVal,nColorBins,nClusters,colorPossibilities);
    case 'speed'
        %calculate mean yposition
        clusterVal = nan(nClusters,1);
        speed = sqrt(clusterDataFrames(5,:).^2 + clusterDataFrames(6,:).^2);
        for clusterInd = 1:nClusters
            clusterVal(clusterInd) = mean(speed(clusters==clusterInd));
        end
        colorPossibilities = parula(nColorBins);
        colors = getColorByMap(clusterVal,nColorBins,nClusters,colorPossibilities);
    case 'netEv'
        clusterVal = nan(nClusters,1);
        for clusterInd = 1:nClusters
            matchInd = find(clusters==clusterInd);
            matchingTrials = unique(clusterTrialIDs(1,matchInd));
            grabTrials = matchingTrials(matchingTrials > 0);
            if isempty(grabTrials)
                clusterVal(clusterInd) = 0;
            else
                segRanges = 0:80:400;
                netEvidence = getNetEvidence(dataCell);
                netEvArray = nan(length(matchInd),1);
                for currMatch = 1:length(matchInd)
                    trialInd = clusterTrialIDs(1,matchInd(currMatch));
                    if trialInd == 0
                        netEvArray(currMatch) = 0;
                        continue;
                    end
                    %                     frameInd = matchInd(find(clusterTrialIDs(1,matchInd)==grabTrials(trialInd),1,'first'));
                    yPosition = clusterDataFrames(3,matchInd(currMatch));
                    if yPosition > 0
                        netEvArray(currMatch) = netEvidence(trialInd,find(yPosition>segRanges,1,'last'));
                    else
                        netEvArray(currMatch) = 0;
                    end
                end
                clusterVal(clusterInd) = mean(netEvArray);
            end
        end
        colorPossibilities = redblue(nColorBins);
        colors = getColorByMap(clusterVal,nColorBins,nClusters,colorPossibilities);
    case 'leftTurn'
        clusterVal = nan(nClusters,1);
        for clusterInd = 1:nClusters
            matchInd = find(clusters==clusterInd);
            matchingTrials = unique(clusterTrialIDs(1,matchInd));
            grabTrials = matchingTrials(matchingTrials > 0);
            if isempty(grabTrials)
                clusterVal(clusterInd) = 0.5;
            else
                segRanges = 0:80:400;
                netEvidence = getNetEvidence(dataCell);
                leftTurnArray = nan(length(matchInd),1);
                for currMatch = 1:length(matchInd)
                    trialInd = clusterTrialIDs(1,matchInd(currMatch));
                    if trialInd == 0
                        leftTurnArray(currMatch) = 0.5;
                        continue;
                    end
                    leftTurnArray(currMatch) = double(dataCell{trialInd}.result.leftTurn);
                end
                clusterVal(clusterInd) = mean(leftTurnArray);
            end
        end
        colorPossibilities = redblue(nColorBins);
        colors = getColorByMap(clusterVal,nColorBins,nClusters,colorPossibilities);
    case 'prevTurn'
        clusterVal = nan(nClusters,1);
        for clusterInd = 1:nClusters
            matchInd = find(clusters==clusterInd);
            matchingTrials = unique(clusterTrialIDs(1,matchInd));
            prevTurnArray = nan(length(matchInd),1);
            for currMatch = 1:length(matchInd)
                trialInd = clusterTrialIDs(1,matchInd(currMatch));
                if trialInd == 0
                    tempArray = clusterTrialIDs(1,matchInd(currMatch):end);
                    trialInd = tempArray(find(tempArray > 0,1,'first'));
                end
                prevTurnArray(currMatch) = double(dataCell{trialInd}.result.prevTurn);
            end
            clusterVal(clusterInd) = mean(prevTurnArray);
        end
        colorPossibilities = redblue(nColorBins);
        colors = getColorByMap(clusterVal,nColorBins,nClusters,colorPossibilities);
    otherwise
        warning('Can''t process colorBy, no color');
        colors = ones(nClusters,3);
end

%cluster size 
clusterSize = nan(nClusters,1);
for clusterInd = 1:nClusters
    clusterSize(clusterInd) = sum(clusters == uniqueClusters(clusterInd));
end
clusterSize = clusterSize/length(clusters);

pngPath = convertTransMatToGraphViz(transMat,colors);

%load image
% img = imread(pngPath);

%create figure and plot
figure;
imshow(pngPath,'InitialMagnification','fit');
colormap(colorPossibilities);
cBar = colorbar;
cBar.Label.String = colorBy;
cBar.TickLabels = cBar.Ticks*range(clusterVal) + min(clusterVal);

end

function colors = getColorByMap(clusterVal,nColorBins,nClusters,colorPossibilities)
clusterVal = roundtowardvec(clusterVal,linspace(min(clusterVal),max(clusterVal),nColorBins));
uniqueVals = unique(clusterVal);
colors = nan(nClusters,3);
for clusterInd = 1:nClusters
    colors(clusterInd,:) = colorPossibilities(clusterVal(clusterInd)==uniqueVals,:);
end
end


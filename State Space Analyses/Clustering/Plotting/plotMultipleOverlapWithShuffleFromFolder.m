function handles = plotMultipleOverlapWithShuffleFromFolder(folder,fileStr,correlation)
%plotMultipleDeltaSegFromFolder.m Plots multiple delta seg offset
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

if nargin < 3 || isempty(correlation)
    correlation = false;
end

pointLabels = {'Maze Start','Segment 1','Segment 2','Segment 3','Segment 4',...
    'Segment 5','Segment 6','Early Delay','Late Delay','Turn'};
nPoints = 10;

%get list of files in folder 
[allNames, ~, ~, ~, isDirs] = dir2cell(folder);
files = allNames(~isDirs);

%match string 
matchFiles = files(~cellfun(@isempty,regexp(files,fileStr)));

%loop through each file and create array 
plotDataDiag = nan(length(matchFiles),nPoints);
plotDataOffDiag = nan(length(matchFiles),nPoints);
plotDataShuffleOffDiag = cell(length(matchFiles),1);
plotDataShuffleDiag = cell(length(matchFiles),1);
for fileInd = 1:length(matchFiles)
    currFileData = load(fullfile(folder,matchFiles{fileInd}));
    field = fieldnames(currFileData);
    plotDataOffDiag(fileInd,:) = currFileData.(field{1}).offDiag; 
    plotDataDiag(fileInd,:) = currFileData.(field{1}).diag; 
    plotDataShuffleOffDiag{fileInd} = currFileData.(field{1}).shuffleOffDiag;
    plotDataShuffleDiag{fileInd} = currFileData.(field{1}).shuffleDiag;
end

%nFiles
nFiles = length(matchFiles);


%% plot 1 
% %create figure and axes
% handles.fig = figure;
% handles.ax = axes;
% 
% %convert shuffle to means across points and get mean and sem
plotShuffleOffDiag = cellfun(@(x) mean(x,2),plotDataShuffleOffDiag,'UniformOutput',false);
plotShuffleOffDiag = cat(2,plotShuffleOffDiag{:});
% meanShuffle = nanmean(plotShuffleOffDiag);
% semShuffle = calcSEM(plotShuffleOffDiag);
% 
% if correlation
%     plotShuffleDiag = cellfun(@(x) mean(x,2),plotDataShuffleDiag,'UniformOutput',false);
%     plotShuffleDiag = cat(2,plotShuffleDiag{:});
%     meanShuffleDiag = nanmean(plotShuffleDiag);
%     semShuffleDiag = calcSEM(plotShuffleDiag);
% end
% 
% %plot bar 
% if correlation
%     barData = cat(2,mean(plotDataDiag,2),mean(plotDataOffDiag,2));
%     barError = cat(2,calcSEM(plotDataDiag,2),calcSEM(plotDataOffDiag,2));
% else
%     barData = cat(2,mean(plotDataDiag,2),mean(plotDataOffDiag,2),meanShuffle');
%     barError = cat(2,calcSEM(plotDataDiag,2),calcSEM(plotDataOffDiag,2),semShuffle');
% end
% [barH,errH] = barwitherr(barError,barData);
% 
% %change colors 
% colors = lines(4);
% barH(1).FaceColor = colors(1,:);
% barH(2).FaceColor = colors(2,:);
% if ~correlation
%     barH(3).FaceColor = colors(3,:);
% %     barH(4).FaceColor = colors(4,:);
% end
% 
% %get significance and plot 
% for fileInd = 1:nFiles
%     if correlation
%         [~,sig] = ttest2(plotDataDiag(fileInd,:),plotDataOffDiag(fileInd,:));
%         bracketX = [errH(1).XData(fileInd) errH(2).XData(fileInd)];
%         groups = {bracketX([1 2])};
%     else
%         sig = nan(length(errH),1);
%         [~,sig(1)] = ttest2(plotDataDiag(fileInd,:),plotDataOffDiag(fileInd,:));
%         [~,sig(2)] = ttest2(plotDataDiag(fileInd,:),plotShuffleOffDiag(fileInd,:));
%         [~,sig(3)] = ttest2(plotDataOffDiag(fileInd,:),plotShuffleOffDiag(fileInd,:));
%         
%         bracketX = [errH(1).XData(fileInd) errH(2).XData(fileInd) errH(3).XData(fileInd)];
%         groups = {bracketX([1 2]),bracketX([1 3]),bracketX([2 3])};
%     end
%     sigH = sigstar(groups,sig,false);
%     for h = 1:numel(sigH)
%         if isprop(sigH(h),'Type') && strcmp(sigH(h).Type,'text')
%             sigH(h).FontSize = 30;
%         end
%     end
%     
% end
% 
% %set axis to square
% axis(handles.ax,'square');
% 
% %set error line width
% [errH(:).LineWidth] = deal(1.5);
% 
% %label axes
% handles.ax.FontSize = 20;
% handles.ax.LabelFontSizeMultiplier = 1.5;
% handles.ax.XLabel.String = 'Imaging session (one per mouse)';
% if correlation
%     handles.ax.YLabel.String = 'Mean correlation coefficient';
% else
%     handles.ax.YLabel.String = 'Mean overlap index';
% end
% 
% %maximize 
% handles.fig.Units = 'normalized';
% handles.fig.OuterPosition = [0 0 1 1];
% 
% %add legend 
% if correlation 
%     labels = {'Intra-state','Inter-state'};
% else
%     labels = {'Intra-state','Inter-state','Shuffled cell labels'};
% end
% legend(barH,labels,'Location','BestOutside');

%% plot 2 
figH = figure;
axH = axes; 

%get mean and sem for each 
meanDiag = mean(plotDataDiag(:));
meanOffDiag = mean(plotDataOffDiag(:));
semDiag = calcSEM(plotDataDiag(:));
semOffDiag = calcSEM(plotDataOffDiag(:));
semShuffle = calcSEM(plotShuffleOffDiag(:));
meanMeanShuffle = mean(plotShuffleOffDiag(:));


%plot bar 
% barData = cat(2,meanDiag,meanOffDiag,meanMeanShuffle);
% barError = cat(2,semDiag,semOffDiag,semShuffle);
% barData = repmat(barData,2,1);
% barError = repmat(barError,2,1);
% [barH,errH] = barwitherr(barError,barData);

hold(axH,'on');
barDiag = barwitherr(semDiag,1,meanDiag);
barOffDiag = barwitherr(semOffDiag,2,meanOffDiag);
barShuffle = barwitherr(semShuffle,3,meanMeanShuffle);

%change colors 
colors = lines(3);
barDiag.FaceColor = colors(1,:);
barOffDiag.FaceColor = colors(2,:);
barShuffle.FaceColor = colors(3,:);
% barH(1).FaceColor = colors(1,:);
% barH(2).FaceColor = colors(2,:);
% barH(3).FaceColor = colors(3,:);

%add significance 
sig = nan(3,1);
[~,sig(1)] = ttest2(plotDataDiag(:),plotDataOffDiag(:));
[~,sig(2)] = ttest2(plotDataDiag(:),plotShuffleOffDiag(:));
[~,sig(3)] = ttest2(plotDataOffDiag(:),plotShuffleOffDiag(:));

% bracketX = [errH(1).XData(1) errH(2).XData(1) errH(3).XData(1)];
bracketX = 1:3;
groups = {bracketX([1 2]),bracketX([1 3]),bracketX([2 3])};

sigH = sigstar(groups,sig,false);
for h = 1:numel(sigH)
    if isprop(sigH(h),'Type') && strcmp(sigH(h).Type,'text')
        sigH(h).FontSize = 30;
    end
end


%beuatify 
beautifyPlot(figH,axH);

keyboard




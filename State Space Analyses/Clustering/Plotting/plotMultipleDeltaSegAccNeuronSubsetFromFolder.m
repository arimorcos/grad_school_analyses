function handles = plotMultipleDeltaSegAccNeuronSubsetFromFolder(folder,fileStr)
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
nDelta = 9;

%get list of files in folder 
[allNames, ~, ~, ~, isDirs] = dir2cell(folder);
files = allNames(~isDirs);

%match string 
matchFiles = files(~cellfun(@isempty,regexp(files,fileStr)));

%loop through each file and create array 
nSTD = nan(length(matchFiles),nDelta);
shuffledSTD = cell(length(matchFiles),1);
for fileInd = 1:length(matchFiles)
    currFileData = load(fullfile(folder,matchFiles{fileInd}));
    shuffledSTD{fileInd} = cell2mat(cellfun(@(x) x.meanNSTD',currFileData.shuffleDeltaPoint,'UniformOutput',false));
    nSTD(fileInd,:) = currFileData.deltaPoint.meanNSTD;    
end

%nFiles
nFiles = length(matchFiles);

%calculate new nSTD 
newSTD = nan(size(nSTD));
for fileInd = 1:nFiles
    
    %get median and std 
    tempMedian = median(shuffledSTD{fileInd});
    tempSTD = std(shuffledSTD{fileInd});
    
    %get newSTD 
    newSTD(fileInd,:) = (nSTD(fileInd,:) - tempMedian)./tempSTD;   
    
end

handles.fig = figure;
handles.ax = axes;

%hold
hold(handles.ax,'on');

colors = distinguishable_colors(nFiles);

%loop through and plot
for file = 1:nFiles
    plotH = plot(1:nDelta,newSTD(file,:));
    plotH.Color = colors(file,:);
    plotH.LineWidth = 2;
    plotH.Marker = 'o';
    plotH.MarkerFaceColor = colors(file,:);
    
end

%add chance line 
chanceH = line([1 nDelta],[2 2]);
chanceH.LineStyle = '--';
chanceH.Color = 'k';

%set axis to square
axis(handles.ax,'square');

%label axes
handles.ax.XLabel.String = '\Delta Maze Epochs';
handles.ax.YLabel.String = '# standard deviations above chance';
handles.ax.XLabel.FontSize = 30;
handles.ax.YLabel.FontSize = 30;
handles.ax.FontSize = 20;
handles.ax.XTick = 1:nDelta;
handles.ax.XLim = [1 nDelta];

%maximize
handles.fig.Units = 'normalized';
handles.fig.OuterPosition = [0 0 1 1];


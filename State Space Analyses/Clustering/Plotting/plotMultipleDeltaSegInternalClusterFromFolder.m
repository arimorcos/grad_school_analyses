function handles = plotMultipleDeltaSegInternalClusterFromFolder(folder,fileStr)
%plotMultipleDeltaSegInternalClusterFromFolder.m Plots multiple delta seg
%internal cluster prediction from folder
%
%INPUTS 
%folder - path to folder 
%fileStr - string to match files to 
%
%OUTPUTS
%handles - structure of handles 
%
%ASM 4/15

%get list of files in folder 
[allNames, ~, ~, ~, isDirs] = dir2cell(folder);
files = allNames(~isDirs);

%match string 
matchFiles = files(~cellfun(@isempty,regexp(files,fileStr)));

%loop through each file and create array 
deltaPoint = cell(length(matchFiles),1);
for fileInd = 1:length(matchFiles)
    currFileData = load(fullfile(folder,matchFiles{fileInd}));
    deltaPoint{fileInd} = currFileData.deltaPoint; 
end
deltaPoint = cat(1,deltaPoint{:});
%nFiles
nFiles = length(matchFiles);

%create figure and axes
handles.fig = figure;
handles.ax = axes;

%hold 
hold(handles.ax,'on');

%generate colors
colors = distinguishable_colors(nFiles);

%loop through and plot 
nPoints = length(deltaPoint(1).meanProb);
for file = 1:nFiles
    plotH = plot(1:nPoints,deltaPoint(file).meanProb);
    plotH.Color = colors(file,:);
    plotH.LineWidth = 2;
    
    %significance 3
    xVals = 1:nPoints;
    sigInd = deltaPoint(file).sig == 3;
    scatSig3 = scatter(xVals(sigInd),deltaPoint(file).meanProb(sigInd));
    scatSig3.Marker = 'o';
    scatSig3.SizeData = 100;
    scatSig3.MarkerEdgeColor = colors(file,:);
    scatSig3.MarkerFaceColor = colors(file,:);
    
    %significance 2 
    sigInd = deltaPoint(file).sig == 2;
    scatSig2 = scatter(xVals(sigInd),deltaPoint(file).meanProb(sigInd));
    scatSig2.Marker = 'd';
    scatSig2.SizeData = 100;
    scatSig2.MarkerEdgeColor = colors(file,:);
    scatSig2.MarkerFaceColor = colors(file,:);
    
    %significance 1 
    sigInd = deltaPoint(file).sig == 1;
    scatSig1 = scatter(xVals(sigInd),deltaPoint(file).meanProb(sigInd));
    scatSig1.Marker = 's';
    scatSig1.SizeData = 100;
    scatSig1.MarkerEdgeColor = colors(file,:);
    scatSig1.MarkerFaceColor = colors(file,:);
    
    %insiginifcanct
    sigInd = isnan(deltaPoint(file).sig);
    scatInSig = scatter(xVals(sigInd),deltaPoint(file).meanProb(sigInd));
    scatInSig.Marker = '^';
    scatInSig.SizeData = 100;
    scatInSig.MarkerEdgeColor = colors(file,:);

end

if isempty(scatInSig.XData)
    scatInSig.XData = -100;
    scatInSig.YData = 0.3;
end
if isempty(scatSig1.XData)
    scatSig1.XData = -100;
    scatSig1.YData = 0.3;
end
if isempty(scatSig2.XData)
    scatSig2.XData = -100;
    scatSig2.YData = 0.3;
end
if isempty(scatSig3.XData)
    scatSig3.XData = -100;
    scatSig3.YData = 0.3;
end


%set axis to square
axis(handles.ax,'square');

%label axes 
handles.ax.XLabel.String = '\Delta Maze Epochs';
handles.ax.YLabel.String = 'Mean Absolute Difference from Null';
handles.ax.XLabel.FontSize = 30;
handles.ax.YLabel.FontSize = 30;
handles.ax.FontSize = 20;
handles.ax.XTick = 1:nPoints;
handles.ax.XLim = [1 nPoints];

%add legend
handles.leg = legend([scatSig3,scatSig2,scatSig1,scatInSig],...
    {'p < 0.001','p < 0.01','p < 0.05','N.S.'},...
    'Location','NorthEast');

%maximize 
handles.fig.Units = 'normalized';
handles.fig.OuterPosition = [0 0 1 1];


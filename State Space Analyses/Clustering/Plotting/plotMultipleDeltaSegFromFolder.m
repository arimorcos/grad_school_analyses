function handles = plotMultipleDeltaSegFromFolder(folder,fileStr)
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
nSeg = 6;

%get list of files in folder 
[allNames, ~, ~, ~, isDirs] = dir2cell(folder);
files = allNames(~isDirs);

%match string 
matchFiles = files(~cellfun(@isempty,regexp(files,fileStr)));

%loop through each file and create array 
r2 = nan(length(matchFiles),nSeg);
pVal = nan(length(matchFiles),nSeg);
for fileInd = 1:length(matchFiles)
    currFileData = load(fullfile(folder,matchFiles{fileInd}));
    r2(fileInd,:) = currFileData.r2;
    pVal(fileInd,:) = currFileData.pVal;
    
end

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
pThresh = 0.001;
for file = 1:nFiles
    plotH = plot(1:nSeg,r2(file,:));
    plotH.Color = colors(file,:);
%     plotH.Marker = 'o';
%     plotH.MarkerSize = 10;
    plotH.LineWidth = 2;
%     plotH.MarkerFaceColor = colors(file,:);
    xVals = 1:nSeg;
    sigInd = pVal(file,:) <= pThresh;
    scatSig = scatter(xVals(sigInd),r2(file,sigInd));
    scatSig.Marker = 'o';
    scatSig.SizeData = 100;
    scatSig.MarkerEdgeColor = colors(file,:);
    scatSig.MarkerFaceColor = colors(file,:);
    scatInSig = scatter(xVals(~sigInd),r2(file,~sigInd));
    scatInSig.Marker = 'o';
    scatInSig.SizeData = 100;
    scatInSig.MarkerEdgeColor = colors(file,:);
end

if isempty(scatInSig.XData)
    scatInSig.XData = -100;
    scatInSig.YData = 0.3;
end


%set axis to square
axis(handles.ax,'square');

%label axes 
handles.ax.XLabel.String = '\Delta Segments';
handles.ax.YLabel.String = 'R^{2}';
handles.ax.XLabel.FontSize = 30;
handles.ax.YLabel.FontSize = 30;
handles.ax.FontSize = 20;
handles.ax.XTick = 1:nSeg;
handles.ax.XLim = [1 nSeg];

%add legend
handles.leg = legend([scatSig,scatInSig],{sprintf('p <= %.3f',pThresh),sprintf('p > %.3f',pThresh)},...
    'Location','NorthEast');

%maximize 
handles.fig.Units = 'normalized';
handles.fig.OuterPosition = [0 0 1 1];


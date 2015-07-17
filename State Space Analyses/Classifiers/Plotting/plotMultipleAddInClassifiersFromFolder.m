function handles = plotMultipleAddInClassifiersFromFolder(folder,fileStr)
%plotMultipleAddInClassifiersFromFolder.m Plots multiple classifier
%accuracy for neuron add-in analysis
%
%INPUTS 
%folder - path to folder 
%fileStr - string to match files to 
%
%OUTPUTS
%handles - structure of handles 
%
%ASM 7/15

%get list of files in folder 
[allNames, ~, ~, ~, isDirs] = dir2cell(folder);
files = allNames(~isDirs);

%match string 
matchFiles = files(~cellfun(@isempty,regexp(files,fileStr)));

%get nFiles
nFiles = length(matchFiles);

%loop through each file and create array 
allAcc = cell(nFiles,1);
for fileInd = 1:nFiles
    currFileData = load(fullfile(folder,matchFiles{fileInd}));
    allAcc{fileInd} = currFileData.accuracy(:,2:end-2);
end

%get max nNeurons 
nNeurons = cellfun(@(x) size(x,1),allAcc);
maxNeurons = max(nNeurons);

%get peak accuracy for each 
peakAcc = nan(nFiles,maxNeurons);
for fileInd = 1:nFiles
    peakAcc(fileInd,1:nNeurons(fileInd)) = max(allAcc{fileInd}(:,:),[],2)';
end

%smooth each curve 
smoothAcc = peakAcc;
filtSize = 10;
for fileInd = 1:nFiles
    smoothAcc(fileInd,1:nNeurons(fileInd)) = smooth(smoothAcc(fileInd,1:nNeurons(fileInd)),filtSize);
end

%% plot 

handles.fig = figure;
handles.ax = axes;

%hold
hold(handles.ax,'on');

colors = distinguishable_colors(nFiles);

%loop through and plot
for fileInd = 1:nFiles
    plotH = plot(1:nNeurons(fileInd),smoothAcc(fileInd,1:nNeurons(fileInd)));
    plotH.Color = colors(fileInd,:);
    plotH.LineWidth = 2;    
end

%beautify 
beautifyPlot(handles.fig, handles.ax);

%label 
handles.ax.XLabel.String = '# Neurons Used (starting with least selective)';
handles.ax.YLabel.String = 'Peak Accuracy';
handles.ax.YLim = [50 100];
function handles = plotMultipleAddInClassifiersFromFolderWithRed(folder,fileStr)
%plotMultipleAddInClassifiersFromFolderWithRed.m Plots multiple classifier
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
    peakAcc(fileInd,1:nNeurons(fileInd)) = max(allAcc{fileInd}(:,1:100),[],2)';
end

%smooth each curve 
smoothAcc = peakAcc;
filtSize = 10;
for fileInd = 1:nFiles
    smoothAcc(fileInd,1:nNeurons(fileInd)) = smooth(smoothAcc(fileInd,1:nNeurons(fileInd)),filtSize);
end

%get red files 
redFiles = ~cellfun(@isempty, strfind(matchFiles,'red'));

%% plot 

handles.fig = figure;
handles.leftAx = subplot(1,2,1);

%hold
hold(handles.leftAx,'on');

colors = distinguishable_colors(sum(~redFiles));

%loop through and plot
for fileInd = 1:nFiles
    plotH = plot(1:nNeurons(fileInd),smoothAcc(fileInd,1:nNeurons(fileInd)));
    plotH.Color = colors(ceil(fileInd/2),:);
    plotH.LineWidth = 2;    
    if redFiles(fileInd)
        plotH.LineStyle = '--';
    end
end

%beautify 
beautifyPlot(handles.fig, handles.leftAx);

%label 
handles.leftAx.XLabel.String = '# Neurons Used (starting with least selective)';
handles.leftAx.YLabel.String = 'Peak Left-Right Classifier Accuracy';
handles.leftAx.YLim = [50 100];

%% plot normalized fraction 
nBins = 30;
frac = linspace(0, 1, nBins+1);
handles.rightAx = subplot(1,2,2);

%hold
hold(handles.rightAx,'on');

colors = distinguishable_colors(sum(~redFiles));

%loop through and plot
for fileInd = 1:nFiles
    
    %normalize 
    range = round(linspace(1, nNeurons(fileInd), nBins+1));
    tempNormAcc = nan(nBins,1);
    for bin = 1:nBins
        useInd = range(bin):(range(bin+1)-1);
        tempNormAcc(bin) = nanmean(peakAcc(fileInd,useInd));
    end
    
    plotH = plot(frac(2:end),tempNormAcc);
    plotH.Color = colors(ceil(fileInd/2),:);
    plotH.LineWidth = 2;    
    if redFiles(fileInd)
        plotH.LineStyle = '--';
    end
end

%beautify 
beautifyPlot(handles.fig, handles.rightAx);

%label 
handles.rightAx.XLabel.String = 'Fraction of total neurons used';
handles.rightAx.YLabel.String = 'Peak Left-Right Classifier Accuracy';
handles.rightAx.YLim = [50 100];
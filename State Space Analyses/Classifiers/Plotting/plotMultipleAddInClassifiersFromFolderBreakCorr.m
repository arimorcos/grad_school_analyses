function handles = plotMultipleAddInClassifiersFromFolderBreakCorr(folder,fileStr)
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
allAccBreakCorr = cell(nFiles,1);
for fileInd = 1:nFiles
    currFileData = load(fullfile(folder,matchFiles{fileInd}));
    allAcc{fileInd} = currFileData.acc(:,2:end-2);
    allAccBreakCorr{fileInd} = currFileData.acc_break_corr(:,2:end-2);
end

%get max nNeurons 
nNeurons = cellfun(@(x) size(x,1),allAcc);
maxNeurons = max(nNeurons);

%get peak accuracy for each 
peakAcc = nan(nFiles,maxNeurons);
peakAccBreakCorr = nan(nFiles,maxNeurons);
which_bins = 1:110;
for fileInd = 1:nFiles
    peakAcc(fileInd,1:nNeurons(fileInd)) = ...
        max(allAcc{fileInd}(:,which_bins),[],2)';
    peakAccBreakCorr(fileInd,1:nNeurons(fileInd)) = ...
        max(allAccBreakCorr{fileInd}(:,which_bins),[],2)';
end


%% plot normalized fraction 
nBins = 30;
frac = linspace(0, 1, nBins+1);
handles.fig2 = figure;
handles.ax2 = axes;

%hold
hold(handles.ax2,'on');

% colors = distinguishable_colors(nFiles);

%loop through and plot
normAcc = nan(nFiles,nBins);
normAccBreakCorr = nan(nFiles,nBins);
for fileInd = 1:nFiles
    
    %normalize 
    range = round(linspace(1, nNeurons(fileInd), nBins+1));
    for bin = 1:nBins
        useInd = range(bin):(range(bin+1)-1);
        normAcc(fileInd,bin) = nanmean(peakAcc(fileInd,useInd));
        normAccBreakCorr(fileInd,bin) = nanmean(peakAccBreakCorr(fileInd,useInd));
    end
         
end

%get mean and sem 
meanVal = mean(normAcc);
semVal = calcSEM(normAcc);
meanValBreakCorr = mean(normAccBreakCorr);
semValBreakCorr = calcSEM(normAccBreakCorr);

colors = lines(2);
errH = shadedErrorBar(frac(2:end),meanVal,semVal);
color = colors(1,:);
errH.mainLine.Color = color;
errH.patch.FaceColor = color;
errH.patch.FaceAlpha = 0.3;
errH.edge(1).Color = color;
errH.edge(2).Color = color;

errH = shadedErrorBar(frac(2:end),meanValBreakCorr,semValBreakCorr);
color = colors(2,:);
errH.mainLine.Color = color;
errH.patch.FaceColor = color;
errH.patch.FaceAlpha = 0.3;
errH.edge(1).Color = color;
errH.edge(2).Color = color;

%beautify 
beautifyPlot(handles.fig2, handles.ax2);

%label 
handles.ax2.XLabel.String = 'Fraction of total neurons used';
handles.ax2.YLabel.String = 'Peak Left-Right Classifier Accuracy';
handles.ax2.YLim = [50 100];
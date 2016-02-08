function handles = plotMultipleNetEvidenceAddInClassifiersFromFolderBreakCorr(folder,fileStr)
%plotMultipleNetEvidenceAddInClassifiersFromFolder.m Plots multiple classifier
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

useSlope = false;

%get list of files in folder 
[allNames, ~, ~, ~, isDirs] = dir2cell(folder);
files = allNames(~isDirs);

%match string 
matchFiles = files(~cellfun(@isempty,regexp(files,fileStr)));

%get nFiles
nFiles = length(matchFiles);

%loop through each file and create array 
addInCorr = cell(nFiles,1);
addInSlope = cell(nFiles,1);
addInBreakCorr = cell(nFiles,1);
addInBreakSlope = cell(nFiles,1);
for fileInd = 1:nFiles
    currFileData = load(fullfile(folder,matchFiles{fileInd}),...
        'addInCorr','addInSlope','addInBreakCorr','addInBreakSlope');
    addInCorr{fileInd} = currFileData.addInCorr;
    addInSlope{fileInd} = currFileData.addInSlope;
    addInBreakCorr{fileInd} = currFileData.addInBreakCorr;
    addInBreakSlope{fileInd} = currFileData.addInBreakSlope;
end

%get max nNeurons 
nNeurons = cellfun(@(x) size(x,1),addInCorr);
maxNeurons = max(nNeurons);

%get peak accuracy for each 
peakCorr = nan(nFiles,maxNeurons);
peakSlope = nan(nFiles,maxNeurons);
peakBreakCorr = nan(nFiles,maxNeurons);
peakBreakSlope = nan(nFiles,maxNeurons);
for fileInd = 1:nFiles
    peakCorr(fileInd,1:nNeurons(fileInd)) = addInCorr{fileInd};
    peakSlope(fileInd,1:nNeurons(fileInd)) = addInSlope{fileInd};
    peakBreakCorr(fileInd,1:nNeurons(fileInd)) = addInBreakCorr{fileInd};
    peakBreakSlope(fileInd,1:nNeurons(fileInd)) = addInBreakSlope{fileInd};
end

%fix peakSlope
peakSlope(:,1:3) = 0;

%% plot normalized fraction 
nBins = 50;
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
        if useSlope
            normAcc(fileInd,bin) = nanmean(peakSlope(fileInd,useInd));
            normAccBreakCorr(fileInd,bin) = nanmean(peakBreakSlope(fileInd,useInd));
        else
            normAcc(fileInd,bin) = nanmean(peakCorr(fileInd,useInd));
            normAccBreakCorr(fileInd,bin) = nanmean(peakBreakCorr(fileInd,useInd));
        end
    end
         
end

%get mean and sem 
meanVal = mean(normAcc) + 0.1;
semVal = calcSEM(normAcc);
meanValBreakCorr = mean(normAccBreakCorr) + 0.1;
semValBreakCorr = calcSEM(normAccBreakCorr);

colors = lines(2);

%original
color = colors(1,:);
errH = shadedErrorBar(frac(2:end),meanVal,semVal);
errH.mainLine.Color = color;
errH.patch.FaceColor = color;
errH.patch.FaceAlpha = 0.3;
errH.edge(1).Color = color;
errH.edge(2).Color = color;

%break corr
color = colors(2,:);
errH = shadedErrorBar(frac(2:end),meanValBreakCorr,semValBreakCorr);
errH.mainLine.Color = color;
errH.patch.FaceColor = color;
errH.patch.FaceAlpha = 0.3;
errH.edge(1).Color = color;
errH.edge(2).Color = color;

%beautify 
beautifyPlot(handles.fig2, handles.ax2);

%label 
handles.ax2.XLabel.String = 'Fraction of total neurons used';
if useSlope
    handles.ax2.YLabel.String = 'Net evidence slope';
else
    handles.ax2.YLabel.String = 'Net evidence correlation';
end
handles.ax2.YLim = [0 1];
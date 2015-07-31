function handles = plotMultipleDeltaSegOffsetFromFolder(folder,fileStr,whichPlots,binPoints)
%plotMultipleDeltaSegOffsetFromFolder.m Plots multiple classifiers based on a
%specific folder path 
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
if nargin < 4 || isempty(binPoints)
    binPoints = true;
end

if nargin < 3 || isempty(whichPlots)
    whichPlots = 1:nSeg;
end

%get list of files in folder 
[allNames, ~, ~, ~, isDirs] = dir2cell(folder);
files = allNames(~isDirs);

%match string 
matchFiles = files(~cellfun(@isempty,regexp(files,fileStr)));

%loop through each file and create array 
deltaSegStart = cell(length(matchFiles),1);
rOffset = cell(size(deltaSegStart));
deltaSegEnd = cell(size(deltaSegStart));
for fileInd = 1:length(matchFiles)
    currFileData = load(fullfile(folder,matchFiles{fileInd}));
    deltaSegStart{fileInd} = currFileData.deltaSegStart;
    rOffset{fileInd} = currFileData.rOffset;
    deltaSegEnd{fileInd} = currFileData.deltaSegEnd;
end

%concatenate all 
nFiles = length(matchFiles);
allStart = cell(nSeg,1);
allEnd = cell(nSeg,1);
for file = 1:nFiles
    for seg = 1:nSeg
        allStart{seg} = cat(2,allStart{seg},deltaSegStart{file}{seg});
        allEnd{seg} = cat(2,allEnd{seg},deltaSegEnd{file}{seg});
    end
end

%calculate r 
r = nan(nSeg,1);
for seg = 1:nSeg
    corr = corrcoef(allStart{seg},allEnd{seg});
    r = corr(1,2);
end

%create figure 
figH = figure;

nPlots = length(whichPlots);
[nRows,nCol] = calcNSubplotRows(nPlots);

%loop through ecah plot
for plotInd = 1:nPlots
    axH = subplot(nRows,nCol,plotInd);
    %scatter
    if binPoints
        nBins = 25;
        binEdges = linspace(min(deltaSegStart{whichPlots(plotInd)}),...
            max(deltaSegStart{whichPlots(plotInd)}),nBins+1);
        
        %get mean in each bin
        meanEnd = nan(nBins,1);
        semEnd = nan(nBins,1);
        meanStart = binEdges(1:end-1) + diff(binEdges);
        for binInd = 1:nBins
            matchInd = deltaSegStart{whichPlots(plotInd)} >= binEdges(binInd) &...
                deltaSegStart{whichPlots(plotInd)} < binEdges(binInd+1);
            
            meanEnd(binInd) = mean(deltaSegEnd{whichPlots(plotInd)}(matchInd));
            semEnd(binInd) = calcSEM(deltaSegEnd{whichPlots(plotInd)}(matchInd)');
        end
        scatH = errorbar(meanStart,meanEnd,semEnd);
        
        allPoints = cat(1,meanStart',meanEnd);
        lims = [min(allPoints) max(allPoints)];
        
        %fill in markers
        scatH.Marker = 'o';
        scatH.MarkerFaceColor = 'b';
        scatH.LineWidth = 2;
        scatH.Color = 'b';
        scatH.MarkerEdgeColor = 'b';
        scatH.LineStyle = 'none';
    else
        scatH = scatter(deltaSegStart{whichPlots(plotInd)},deltaSegEnd{whichPlots(plotInd)});
        
        allPoints = cat(2,deltaSegStart{whichPlots(plotInd)},deltaSegEnd{whichPlots(plotInd)});
        lims = [min(allPoints) max(allPoints)];
    end
    axis(axH,'square');
    
    
    
    %get allPoints
    axH.XLim = lims;
    axH.YLim = lims;
    hold(axH,'on');
    
    %calculate correlation coefficient
    [corr,pVal] = corrcoef(deltaSegStart{whichPlots(plotInd)},deltaSegEnd{whichPlots(plotInd)});
    textH = text(lims(1)+0.01*range(lims),lims(2)-0.01*range(lims),...
        sprintf('R^{2}: %.3f, p = %.4d',corr(2,1)^2,pVal(2,1)));
    textH.FontSize = 20;
    textH.VerticalAlignment = 'top';
    textH.HorizontalAlignment = 'Left';
    r2(plotInd) = corr(2,1)^2;
    
    %add line of unity
    lineH = line(lims,lims);
    lineH.Color = 'k';
    lineH.LineStyle = '--';
    
    %fit lines and plot
    fitCoeff = robustfit(deltaSegStart{plotInd},deltaSegEnd{plotInd});
    slope(plotInd) =fitCoeff(2);
    
    %title
    axH.Title.String = sprintf('\\Delta%d Segments',whichPlots(plotInd));
    axH.FontSize = 20;
    
end


%label axes
if length(whichPlots) > 1
    yLab = suplabel('End distance (euclidean)','y');
    xLab = suplabel('Start distance (euclidean)','x');
    xLab.FontSize = 30;
    yLab.FontSize = 30;
else
    axH.LabelFontSizeMultiplier = 1.5;
    axH.YLabel.String = 'End distance (euclidean)';
    axH.XLabel.String = 'Start distance (euclidean)';
end
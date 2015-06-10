function plotWeightSlopeVsDeltaPLeft(folder,fileStr)
%plotWeightSlopeVsDeltaPLeft.m Plots multiple delta pLeft from folder
%
%INPUTS
%folder - path to folder
%fileStr - string to match files to
%
%OUTPUTS
%handles - structure of handles
%
%ASM 4/15

showLegend = true;

%% get data
%get list of files in folder 
[allNames, ~, ~, ~, isDirs] = dir2cell(folder);
files = allNames(~isDirs);

%match string 
matchFiles = files(~cellfun(@isempty,regexp(files,fileStr)));
nFiles = length(matchFiles);

%loop through each file and create array 
confInt = cell(nFiles,1);
deltaPLeft = cell(nFiles,1);
netEvidence = cell(nFiles,1);
segWeights = cell(nFiles,1);
for fileInd = 1:nFiles
    currFileData = load(fullfile(folder,matchFiles{fileInd}));
    confInt{fileInd} = currFileData.confInt;
    netEvidence{fileInd} = currFileData.netEvidence;
    deltaPLeft{fileInd} = currFileData.deltaPLeft;
    segWeights{fileInd} = currFileData.segWeights;
end

%% get slopes 
nSeg = length(segWeights{1});

%initialize 
segSlope = nan(nFiles,1);
pLeftSlope = nan(nFiles,1);

%loop through each dataset 
for dSet = 1:nFiles
    
    %fit segment weights
    segModel = fitlm(1:nSeg,segWeights{dSet});
    segSlope(dSet) = segModel.Coefficients.Estimate(2);
    
    %fit pLeft slope 
    tempDeltaPLeft = deltaPLeft{dSet}(:,1:nSeg);
    xVals = repmat(1:nSeg,size(tempDeltaPLeft,1),1);
    pLeftModel = fitlm(xVals(:),tempDeltaPLeft(:));
    pLeftSlope(dSet) = pLeftModel.Coefficients.Estimate(2);
     
end

%% plot 

if showLegend 
    colors = distinguishable_colors(nFiles);
end

handles.fig = figure;
handles.ax = axes;

%scatter 
if showLegend
    hold(handles.ax,'on');
    handles.scatH = gobjects(nFiles,1);
    for file = 1:nFiles
        handles.scatH(file) = scatter(segSlope(file),pLeftSlope(file));
        handles.scatH(file).SizeData = 150;
        handles.scatH(file).MarkerEdgeColor = colors(file,:);
        handles.scatH(file).MarkerFaceColor = handles.scatH(file).MarkerEdgeColor;
    end
else
    handles.scatH = scatter(segSlope,pLeftSlope);
    handles.scatH.MarkerFaceColor = handles.scatH.MarkerEdgeColor;
end


%beautify 
beautifyPlot(handles.fig,handles.ax);

%label 
handles.ax.XLabel.String = 'Segment Weights Slope';
handles.ax.YLabel.String = '\Delta P(LeftTurn) Slope';

%add legend
if showLegend
    legend(handles.scatH,strrep(matchFiles,'_','\_'),'Location','BestOutside');
end
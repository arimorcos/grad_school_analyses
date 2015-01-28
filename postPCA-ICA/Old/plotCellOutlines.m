function plotCellOutlines(askForFile,filteredSegAll,zProj,filteredCentroids,cellIDs)
%plotCellOutlines.m Plots cell outlines over projected image with number
%IDs
%
%INPUTS
%askForFile - should ask for file and load? If empty, no.
%filteredSegAll - m x n x nCells array of filters
%zProj - m x n projected image
%filteredCentroids - nCells x 2 array of centroid coordinates
%cellIDs - IDs of cells to plot. If empty, plot all.
%
%ASM 10/13

if nargin < 5; cellIDs = []; end
if nargin < 1; askForFile = true; end;
if isempty(askForFile); askForFile = false; end;

%ask for file if necessary
if askForFile
    %change to directory
    origDir = cd('D:\DATA\2P Data\ResScan\');
    
    %get file
    [tifName,tifPath] = uigetfile('*.tif');
    tifFile = fullfile(tifPath,tifName);
    tiffBase = tifName(1:regexp(tifName,'.tif')-1);
    ICAFile = [fullfile(tifPath,tiffBase),'_postICA.mat'];
    
    
    %load tiff
    zProj = sum(loadtiffAM(tifFile),3);
    
    %load in other variables
    if exist(ICAFile,'file')
        load(ICAFile,'filteredSegAll','filteredCentroids');
    else
        error('No associated postICA file present');
    end
    
    %change back to original directory
    cd(origDir);
end

%get nCells
nCells = size(filteredSegAll,3);

%cellIDS
if isempty(cellIDs)
    cellIDs = 1:nCells;
else
    nCells = length(cellIDs);
end

%find edges
edgeInd = cell(2,nCells);
for i = 1:nCells %for each cell
    [edgeInd{1,i},edgeInd{2,i}] = findEdges(filteredSegAll(:,:,cellIDs(i)));
end

%plot 
figH = figure('Name','All Cells');
imshow(zProj,[]); %show image
hold on;
colorProfile = distinguishable_colors(nCells);
for i = 1:nCells % for each cell
    
    %plot cell
    plot(edgeInd{1,i},edgeInd{2,i},'Color',colorProfile(i,:));
    
    %label
    text(filteredCentroids(cellIDs(i),1),filteredCentroids(cellIDs(i),2),num2str(i),'Color',...
        colorProfile(i,:),'HorizontalAlignment','Center');
    
end


    
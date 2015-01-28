function [filteredSegAll, filteredSegNonOverlap, filteredSegNonOverlapProj,...
    filteredCentroids] = runPCAICA(shouldSave)
%runPCAICA.m Master function to run PCA/ICA analysis based on Mukamel et
%al.
%
%INPUTS
%shouldSave - boolean for whether or not to save output file
%
%
%
%OUTPUTS
%filteredSegAll - m x n x nFilters array containing each of the spatial
%   filters
%filteredSegNonOverlap - m x n x nFilters array containing each of the
%   spatial filters with overlapping sections removed
%filteredSegNonOverlapProj - m x n image containing a projection of all
%   filters with overlapping sections removed
%filteredCentroids - centroids of segments
%
%ASM 10/13

if nargin < 1
    shouldSave = true;
end

%get tiff
[tifName,tifPath] = uigetfile('*.tif','Select Tiff File');
fileName = fullfile(tifPath,tifName);
outputDir = tifPath;

%initialize parameters
%get nFrames
nFrames = getNPages(fileName);

%badFrames info
corrThresh = 0.77; %correlation threshold for finding bad frames
downsampleFac = 1; %downsample factor to increase speed for finding bad frames

%PCA variables
frameLimits = [1 nFrames]; %2-element vector specifiyinm the endpoints of range of frames to be analyzed. All if empty.
nPCs = 250; %number of principal components to return
dsamp = [2,2]; 
badFrames = [];
% badFrames = findBadFrames(fileName,corrThresh,downsampleFac);
savePCA = false; %should save pca

%ICA variables
mu = 0.2; %parameter between 0 and 1 specifying ratio of temporal to spatial ICA. 
nICs = []; %number of ICs to derive
initialICAguess = []; %initial guess for ICA. Should be nPCs x nICs
termTolerance = []; %fractional change in output at which to end iteration
maxRounds = 1000; %maximum number of rounds of iterations

%segmentation variables
segThresh = 5; %threshold for spatial filters(std)
smoothWidth = 3; %standard deviation of smoothing kernel
areaLimits = [75]; %2-element vector of min and max area (in pixels). If scalar, just min
shouldPlotFilters = false; %boolean of whether or not to plot filters

%cell processing
micronsPerPix = 1; %microns per pixel
minArea = 75; %min area in microns^2
maxArea = 600; %max area in microns^2
overlapThresh = 0.6; %overlap threshold for considering the same cell

%run PCA
[mixedSig, mixedFilters, covEigenvalues, ~, ~, ~] =...
    CellsortPCA(fileName, frameLimits, nPCs, dsamp, outputDir, badFrames, savePCA);

%select PCs
[PCuse] = CellsortChoosePCs(fileName, mixedFilters);

%perform ICA
[~, ica_filters, ~ , ~] =  ...
  CellsortICA(mixedSig, mixedFilters, covEigenvalues, PCuse, mu, nICs,...
  initialICAguess, termTolerance, maxRounds);

%segment
[ica_segments, ~, segmentCentroids] = CellsortSegmentation(...
    ica_filters, smoothWidth, segThresh, areaLimits, shouldPlotFilters);

%fix dimensions
ica_segments = fixDimensions(ica_segments);

if shouldSave
    ICAFileName = [fileName(1:regexp(fileName,'.tif')-1),'_postICA.mat'];
    save(ICAFileName,'ica_segments');
end

%binarize and project
[binarySeg, binarySegProj] = binarizeProjectICASeg(ica_segments);

%apply filters
[filteredSegAll,keptSeg] = filterICAFilters(binarySeg,micronsPerPix,minArea,maxArea,overlapThresh);

%get new centroids
filteredCentroids = segmentCentroids(keptSeg,:);

%remove overlapping regions
[filteredSegNonOverlap, filteredSegNonOverlapProj] = removeOverlaps(filteredSegAll,binarySegProj); 

%save
if shouldSave
    ICAFileName = [fileName(1:regexp(fileName,'.tif')-1),'_postICA.mat'];
    save(ICAFileName,'filteredSegAll','filteredSegNonOverlap','filteredSegNonOverlapProj',...
        'filteredCentroids','-append');
end
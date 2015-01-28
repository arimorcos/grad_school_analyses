% script to test pca-ica analysis based on Mukamel et al. 2009

%% initialize variables

%file to load
% fileName = 'D:\DATA\2P Data\2P1\Data\Caroline test\A1_3_001\A1_3_001_Plane001_motionCorrected.tif';  
% outputDir = 'D:\DATA\2P Data\2P1\Data\Caroline test\A1_3_001';
% fileName = 'D:\DATA\2P Data\ResScan\Laura\LD082_130825_006_cat\LD082_130825_006_cat_Plane004_motionCorrected_binned.tif';
% outputDir = 'D:\DATA\2P Data\ResScan\Laura\LD082_130825_006_cat';
fileName = 'K:\DATA\2P Data\ResScan\AM115\140227\AM115_1_3x_119Sub_001_green_cat_motionCorrected_crop.tif'; 
outputDir = 'K:\DATA\2P Data\ResScan\AM115\140227';

%get tiff info
tiffInfo = imfinfo(fileName);
nPixels = tiffInfo(1).Width*tiffInfo(1).Height; %get number of pixels

%badFrames info
corrThresh = 0.77; %correlation threshold for finding bad frames
downsampleFac = 0.5; %downsample factor to increase speed for finding bad frames

%PCA variables
frameLimits = [1 length(tiffInfo)]; %2-element vector specifiyinm the endpoints of range of frames to be analyzed. All if empty.
nPCs = 250; %number of principal components to return
dsamp = []; 
badFrames = []; %list of frames to exclude
savePCA = false; %should save pca

%ICA variables
mu = 0.5; %parameter between 0 and 1 specifying ratio of temporal to spatial ICA. 
nICs = []; %number of ICs to derive
initialICAguess = []; %initial guess for ICA. Should be nPCs x nICs
termTolerance = []; %fractional change in output at which to end iteration
maxRounds = 1000; %maximum number of rounds of iterations

%IC plot variables
plotMode = 'contour'; %'series' shows each filter differently. 'contour' shows a single plot with contour outlines
meanFImage = imread(fileName);
frameRate = 15.62;
dT = 1/frameRate; 
timeLimits = [];
binLength = 5;
plotType = 1;
ICuse = [];
%%
%segmentation variables
segThresh = 3.5; %threshold for spatial filters(std)
smoothWidth = 3; %standard deviation of smoothing kernel
areaLimits = [50]; %2-element vector of min and max area (in pixels). If scalar, just min
shouldPlotFilters = false; %boolean of whether or not to plot filters

%cell processing
micronsPerPix = 0.8; %microns per pixel
minArea = 50; %min area in microns^2
maxArea = 600; %max area in microns^2
overlapThresh = 0.6; %overlap threshold for considering the same cell

%% find bad frames to exclude
badFrames = findBadFrames(fileName,corrThresh,downsampleFac);

%% run PCA
% [mixedSig, mixedFilters, covEigenvalues, covTrace, movm, movtm] =...
%     CellsortPCA(fileName, frameLimits, nPCs, dsamp, outputDir, badFrames, savePCA);
[mixedSig,mixedFilters,covEigenvalues] = fastCellSortPCA(fileName,nPCs);

%% CellsortChoosePCs
[PCuse] = CellsortChoosePCs(fileName, mixedFilters);

%% CellsortPlotPCspectrum
CellsortPlotPCspectrum(fileName, covEigenvalues, PCuse);

%% CellsortICA
[ica_sig, ica_filters, ica_A , nIterations] =  ...
  CellsortICA(mixedSig, mixedFilters, covEigenvalues, PCuse, mu, nICs,...
  initialICAguess, termTolerance, maxRounds);

%% CellsortICAplot
CellsortICAplot(plotMode, ica_filters, ica_sig, meanFImage, timeLimits, dT,...
    binLength, plotType, ICuse);

%% CellsortSegmentation
[ica_segments, segmentLabels, segmentCentroids] = CellsortSegmentation(...
    ica_filters, smoothWidth, segThresh, areaLimits, shouldPlotFilters);

% fix dimensions
ica_segments = fixDimensions(ica_segments);

% initial analysis
%binarize and project
[binarySeg, binarySegProj] = binarizeProjectICASeg(ica_segments);

%apply filters
[filteredSeg,keptSeg] = filterICAFilters(binarySeg,micronsPerPix,minArea,maxArea,overlapThresh);

%remove overlapping regions
[filteredSegNonOverlap, filteredSegNonOverlapProj] = removeOverlaps(filteredSeg,binarySegProj); 

%%
%save
ICAFileName = [fileName(1:regexp(fileName,'.tif')-1),'_postICA.mat'];
save(ICAFileName,'ica_segments','filteredSeg','filteredSegNonOverlap','filteredSegNonOverlapProj');

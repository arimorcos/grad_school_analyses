function [dFFTraces] = postICAProcessing(shouldSave,tiffFile,percentileVal,window,frameRate)
%postICAProcessing.m Extracts dFF traces and saves
%
%INPUTS
%shouldSave - should save values? Default true
%tiffFile - path and filename of tiff. If empty, asks for file
%percentileVal - percentile of average to set as baseline
%window - window in seconds around which to calculate baseline
%frameRate - frameRate of acquisition
%
%OUTPUTS
%dFFTraces - nFilters x nFrames array containing dF/F as percentage
%
%
%ASM 10/13

if nargin < 5 || isempty(frameRate)
    frameRate = 5.67;
end
if nargin < 4 || isempty(window)
    window = 20;
end
if nargin < 3 || isempty(percentileVal)
    percentileVal = 8;
end
if nargin < 2 || isempty(tiffFile)
    %get tiff
    origDir = cd('K:\DATA\2P Data\ResScan');
    [tiffName,tiffPath] = uigetfile('*.tif');
    tiffFile = fullfile(tiffPath,tiffName);
    tiffBase = tiffName(1:regexp(tiffName,'.tif')-1);
    cd(origDir);
else
    [tiffPath,tiffBase] = fileparts(tiffFile);
end
if nargin < 1 || isempty(shouldSave)
    shouldSave = true;
end

%Load tiff
fprintf('Loading tiff...');
tiff = loadtiffAM(tiffFile);
fprintf('Complete\n');

%check if postICA or manual
postICAName = [fullfile(tiffPath,tiffBase),'_postICA.mat'];
manualName = [fullfile(tiffPath,tiffBase),'_manualROI.mat'];
if exist(postICAName,'file')
    load(postICAName,'filteredSegNonOverlap');
elseif exist(manualName,'file')
    load(manualName,'ROIs');
    filteredSegNonOverlap = ROIs;
    clear ROIs;
end

%get dFFTraces
fprintf('Getting dF/F traces...');
[dFFTraces,meanF,baseline] = getDFFTraces(tiff,filteredSegNonOverlap,...
    percentileVal,window,frameRate);
fprintf('Complete\n');

%save
if shouldSave
    fprintf('Saving...');
    dFFName = [fullfile(tiffPath,tiffBase),'_dFFData.mat'];
    save(dFFName,'dFFTraces','meanF','baseline');
    fprintf('Complete\n');
end
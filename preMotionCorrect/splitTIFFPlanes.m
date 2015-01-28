function [tiffNames,tiffPaths,tiffFiles] = ...
    splitTIFFPlanes(tiff,baseName,nPlanes,nExtraPlanes,savePath,channelLabels)
%splitTIFFPlanes.m function to split tiff according to plane for resScan
%scope
%
%INPUTS
%tiff - m x n x nFrames tiff array
%baseName - baseName of tiff
%nPlanes - nPlanes to save
%nExtraPlanes - nPlanes to throw away
%savePath - path to save tiffs
%channelLabels - cell of channel labels. If empty, no channels
%
%OUTPUTS
%tiffNames - 1 x nFiles cell array containing the names of the new tiffs
%tiffPaths - 1 x nFiles cell array containing the paths of the new tiffs
%tiffFiles - 1 x nFiles cell array containing the full path and name of the
%   new tiffs
%
%ASM 9/13

if nargin < 6 || isempty(channelLabels)
    channelLabels = {''};
end

%create save directory
savePath = fullfile(savePath,baseName);
if exist(savePath,'dir') == 0 %if directory does not exist
    mkdir(savePath);
end

%get nFrames and calculate frameStep
nFrames = size(tiff,3);
frameStep = nPlanes + nExtraPlanes;

%initialize outputs
tiffNames = cell(1,nPlanes);
tiffPaths = cell(1,nPlanes);
tiffFiles = cell(1,nPlanes);

% split up tiff by channels
nChannels = length(channelLabels);
tiffChannels = cell(1,nChannels);
for i = 1:nChannels
    channelFramesToKeep = i:nChannels:nFrames;
    tiffChannels{i} = tiff(:,:,channelFramesToKeep);
    
    % append underscore to channel names
    if ~isempty(channelLabels{i})
        channelLabels{i} = [channelLabels{i},'_'];
    end
end



%clear tiff
clear tiff;

%split up tiffs by plane
for i = 1:nChannels
    for j = 1:nPlanes %for each plane
        
        %split up tiff
        framesToKeep = j:frameStep:nFrames;
        splitTiff = tiff(:,:,framesToKeep);
        
        %create outputs
        tiffNames{j} = sprintf('%s_%sPlane%03d.tif',baseName,channelLabels{i},j);
        tiffPaths{j} = savePath;
        tiffFiles{j} = fullfile(tiffPaths{j},tiffNames{j});
        
        %save
        saveasbigtiff(splitTiff,tiffFiles{j});
    end
end
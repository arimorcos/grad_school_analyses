function shrinkTIFF(tiffName, shrinkFac)
%shrinkTIFF.m function to shrink a tiff using the resizeImage matlab
%function
%
%INPUTS
%tiffName - name and path of tiff file
%shrinkFac - factor by which to shrink image (must be less than 1)
%
%ASM 10/13

if nargin < 2; shrinkFac = 0.5; end

if nargin < 1 %if no filename provided
    %ask user for file which should be motion corrected
    [tiffName, tiffPath] = uigetfile('*.tif');
    tiffFile = fullfile(tiffPath,tiffName);
end

%get tiffBase
[~,tiffBase] = regexp(tiffName,'.tif','match','split'); %remove .tif
tiffBase = tiffBase{1};

%load tiff
fprintf('Loading tiff file...');
tiff = loadtiffAM(tiffFile);
fprintf('Complete\n');

%resize tiff
fprintf('Resizing tiff...');
shrunkTiff = imresize(tiff,shrinkFac);
fprintf('Complete\n');

%save shrunk tiff
fprintf('Saving shrunk tiff...');
saveasbigtiff(shrunkTiff,[fullfile(tiffPath,tiffBase),'_binned.tif']);
fprintf('Complete\n');
fprintf(['Shrunk tiff saved as ',tiffBase,'_binned.tif\n']);
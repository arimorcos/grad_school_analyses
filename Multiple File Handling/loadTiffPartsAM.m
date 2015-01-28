function tiff = loadTiffPartsAM(path,fileStr,ind,framesPer)
%loadTiffPartsAM.m Loads proper frames from tiff series
%
%INPUTS
%path - path to files
%fileStr - str match containing wildcards
%ind - indices to load
%framesPerFile - default is 1000
%
%OUTPUTS
%tiff - tiff to load
%
%ASM 5/14

if nargin < 4 || isempty(framesPer)
    framesPer = 1000;
end

%get list of files matching expression
fileList = dir(path);
fileList = {fileList(:).name};

%filter based on file and ext
fileMatch = ~cellfun(@isempty,regexp(fileList,fileStr));
fileList = fileList(fileMatch);

%append folder to all files
fileList = cellfun(@(x) [path,filesep,x],fileList,'UniformOutput',false);

%determine necessary files to load from
frameLocations = bsxfun(@plus,(1:framesPer),(0:framesPer:framesPer*(length(fileList)-1))');

%check which indices match frame locations
frameMatch = ismember(frameLocations,ind);

%get files with frames to load
loadFilesInd = find(sum(frameMatch,2)~=0);
filesToLoad = fileList(loadFilesInd);

%loop through and load
tiff = [];
for i = 1:length(filesToLoad)
    tiff = cat(3,tiff,loadtiffAM(filesToLoad{i},find(frameMatch(loadFilesInd(i),:)==1)));
end
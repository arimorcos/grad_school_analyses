function [avgProj,maxProj] = createMultiTiffProjection(folderPath,fileStr,silent)
%createMultiTiffProjection.m Create projection of tiff from multiple file
%parts in the same folder
%
%INPUTS
%folderPath - path to folder with tiff files
%fileStr - file str to filter based upon
%silent - should be silent
%
%OUTPUTS
%proj - m x n projection image
%
%ASM 5/14

if nargin < 3 || isempty(silent)
    silent = false;
end

%get file list
fileList = getMatchingFileList(folderPath,fileStr);

%get nFiles
nFiles = length(fileList);

%CREATE baseStr
%find \
% slashLoc = strfind(fileStr,'\');
% deleteChar = [min(slashLoc)-1 slashLoc slashLoc + 1];
% baseStr = fileStr;
% baseStr(deleteChar) = [];
% [~,baseStr]=fileparts(baseStr); %remove .tif
[~,fileBases] = cellfun(@fileparts,fileList,'UniformOutput',false); %get list of base strings
baseParts = regexp(fileBases{1},'(?<=\d\d\d_)\d\d\d_(?=Plane)','split');
baseStr = cat(2,baseParts{:});

%create waitbar
if ~silent
    hWait = waitbar(0,sprintf('Creating projection -- file %d/%d',0,nFiles));
end

%loop through each file and load information
nFrames = 0;
for i = 1:nFiles
    
    [tempTiff,~,sImageStr] = loadtiffAM(fileList{i});
    
    %if first index initialize
    if i == 1 
        proj = zeros(size(tempTiff,1),size(tempTiff,2));
    end
    
    %sum
    proj = proj + sum(tempTiff,3);
    
    %get nFrames
    nFrames = nFrames + size(tempTiff,3);
    
    %update waitbar
    if ~silent
        waitbar(i/nFiles,hWait,sprintf('Creating projection -- file %d/%d',i,nFiles));
    end
    
end

%divide by nFrames
maxProj = proj;
avgProj = proj./nFrames;

%blur avgProj and subtract sum of movie
sigma = 3;
gaussProj = imfilter(avgProj, fspecial('gaussian',25,sigma));
gaussProjSub =  avgProj./gaussProj;

%normalize maxProj
maxProj = 65535*mat2gray(maxProj);
gaussProjSub = 65535*mat2gray(gaussProjSub);

%convert to uint16
avgProj = uint16(avgProj);
maxProj = uint16(maxProj);
gaussProjSub = uint16(gaussProjSub);

%save file
saveStr = sprintf('%s%s%s_avgProj.tif',folderPath,filesep,baseStr);
saveastiffAM(avgProj,saveStr,[],{'ImageDescription',sImageStr});
saveStr = sprintf('%s%s%s_maxProj.tif',folderPath,filesep,baseStr);
saveastiffAM(maxProj,saveStr,[],{'ImageDescription',sImageStr});
saveStr = sprintf('%s%s%s_gaussProj.tif',folderPath,filesep,baseStr);
saveastiffAM(gaussProjSub,saveStr,[],{'ImageDescription',sImageStr});

%delete waitbar
if ~silent
    delete(hWait);
end
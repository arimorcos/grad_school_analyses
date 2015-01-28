function fileList = getMatchingFileList(folderPath,fileStr)
%getMatchingFileList.m Grabs matching files in a given folder
%
%INPUTS
%folderPath - path to folder
%fileStr - regexp fileStr to match files to motion correct
%
%ASM 5/14

%get list of files matching expression
fileList = dir(folderPath);
fileList = {fileList(:).name};

%filter based on file and ext
fileMatch = ~cellfun(@isempty,regexp(fileList,fileStr));
fileList = fileList(fileMatch);

%append folder to all files
fileList = cellfun(@(x) [folderPath,filesep,x],fileList,'UniformOutput',false);
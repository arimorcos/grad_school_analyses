function splitChannelsForFolder(folderPath,hWait)
%splitChannelsForFolder.m Function to split channels for all files in a
%folder matching the proper tif format
%
%INPUTS
%folderPath - full path of folder to look in 
%
%ASM 4/14

%create waitbar
if nargin < 2 || isempty(hWait)
    hWait = waitbar(0,'Select file...');
    waitbarGiven = false;
else
    waitbarGiven = true;
end

%get folder if necessary
if nargin < 1 || isempty(folderPath) || ~exist(folderPath,'dir')
    if exist('W:\ResScan','dir')
        startPath = 'W:\ResScan';
    else
        startPath = '';
    end
    folderPath = uigetdir(startPath);
end

%get list of all .tif files in folder
fileList = dir(folderPath);
fileList = {fileList(:).name};

%filter out files without the right format
fileMatch = regexp(fileList,'\d\d\d_\d\d\d.tif');
fileMatch = ~cellfun(@isempty,fileMatch);
fileList = fileList(fileMatch);

%append folder path 
fullFileList = cellfun(@(x) sprintf('%s%s%s',folderPath,filesep,x),fileList,'UniformOutput',false);

%loop through each file and split
for i = 1:length(fileList)
    splitChannels(fullFileList{i},[],true,true,hWait,false);
end

%delete waitbar
if ~waitbarGiven && ishandle(hWait)
    delete(hWait);  
end

end
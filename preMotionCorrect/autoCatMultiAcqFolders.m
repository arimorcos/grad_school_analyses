function [tiffNames, tiffPaths, tiffFiles] = autoCatMultiAcqFolders(folder)
%autoCatMultiAcq.m Automatically searches for multiple acquisitions and
%concatenates proper planes together into single large file saved in
%bigtiff format
%
%INPUTS
%folder - folder to search for multiple acquisitions
%
%OUTPUTS
%tiffNames - 1 x nFiles cell array containing the names of the new tiffs
%tiffPaths - 1 x nFiles cell array containing the paths of the new tiffs
%tiffFiles - 1 x nFiles cell array containing the full path and name of the
%   new tiffs
%
%ASM 10/13

if nargin < 1 || isempty(folder)
    %get folder
    baseDir = 'D:\DATA\2P Data\ResScan';
    folder = uigetdir(baseDir);
    if folder == 0
        return;
    end
end

%break apart folder name
folderParts = explode(folder,filesep);
mouseName = folderParts{end - 1};
date = folderParts{end};

%ensure folder will work
if isnan(str2double(date)) %if contains characters
    error('Last part of folder path must be date');
end
if length(mouseName) ~= 5 || ~all(isletter(mouseName(1:2))) %if isn't 5 characters or doesn't begin with initials or end with number
    error('Second to last part of folder path must be mouseName');
end

%change to folder
origDir = cd(folder);

%search for directories
subFold = dir([mouseName,'*']); %get list of files/folders matching mouseName
subFold = subFold(cell2mat(extractfield(subFold,'isdir'))); %extract directories
subFold = {subFold(:).name}; %convert to cell array

%find number of planes
fileListFirst = dir(fullfile(folder,subFold{1},[subFold{1},'_Plane*.tif']));
fileListFirst = fileListFirst(cell2mat(cellfun(@(dirString)...
    ~isempty(regexp(dirString,[subFold{1},'_Plane\d\d\d.tif'],'ONCE')),...
    {fileListFirst(:).name},'UniformOutput',false)));
nPlanes = length(fileListFirst);

%initialize 
catTiffs = cell(1,length(subFold));
ind = 1;

%create waitbar
numTiffs = nPlanes*length(subFold);
hWait = waitbar(0,sprintf('Loading tif %d out of %d',0,numTiffs));
set(findall(hWait,'type','text'),'Interpreter','none');

%cycle through each folder and add to each plane
for i = 1:length(subFold)
    %change to folder
    cd(fullfile(folder,subFold{i}));
    
    for j = 1:nPlanes %for each plane
        
        %generate tiff string
        tiffStr = sprintf('%s_Plane%03d.tif',subFold{i},j);
        
        %update waitbar
        waitbar(ind/numTiffs,hWait,sprintf('Loading %s...File %d out of %d',...
            tiffStr,ind,numTiffs));
        
        %load tiff
        tiff = loadtiffAM(tiffStr);
        
        %store in catTiffs
        catTiffs{i} = cat(3,catTiffs{i},tiff);
        
        %increment ind
        ind = ind + 1;
    end
end

%initialize save names
tiffNames = cell(1,nPlanes);
tiffPaths = cell(1,nPlanes);
tiffFiles = cell(1,nPlanes);

%save each tiff as new
for i = 1:nPlanes %for each plane
    
    %generate savePath
    tiffFiles{i} = fullfile(folder,sprintf('%s_%s_Plane%03d_cat.tif',mouseName,date,i));
    
    %update waitbar
    waitbar(i/nPlanes,hWait,sprintf('Saving %s_%s_Plane%03d_cat.tif...File %d out of %d',...
        mouseName,date,i,nPlanes));
    
    %save
    saveasbigtiff(catTiffs{i},tiffFiles{i});
end

%extract tiffPaths, names
[tiffPaths,tiffNames,ext] = cellfun(@fileparts,tiffFiles,'UniformOutput',false);
tiffNames = cellfun(@(x,y) [x y],tiffNames,ext,'UniformOutput',false);

%change back to original directory
cd(origDir);
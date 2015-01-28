function folderPaths = findUnprocessedImagingData(rootFolder,singleEntry)
%findUnprocessedImagingData.m Searches through root folder to find folders
%that have not yet been motion corrected
%
%INPUTS
%rootFolder - root folder with all imaging data
%singleEntry - only find one folder. Default is false
%
%OUTPUTS
%folderPaths - 1 x nUnprocessed cell containing folder paths to unprocessed
%   folders
%
%ASM 8/14

if nargin < 2 || isempty(singleEntry)
    singleEntry = false;
end
if nargin < 1 || isempty(rootFolder)
    rootFolder = 'Z:\HarveyLab\Ari\2P Data\ResScan';
end

exclude = {'AM074','AM081','AM090','AM097','AM100','AM108','AM115','AM119',...
    'AM122','AM126','AM132','AP02','AP04','Laura','PClamp Files','.','..'};

unProcString = 'AM\d\d\d.*\d\d\d_\d\d\d.tif$';
procString = 'AM\d\d\d.*\d\d\d_Plane\d\d\d_[a-z]*.tif$';
%%
%change to root folder
origDir = cd(rootFolder);

%get list of all mouse folders
allFilesRoot = dir2cell(rootFolder);

%eliminate not directory folders
allFoldersRoot = allFilesRoot(cellfun(@isdir,allFilesRoot));

%remove files which match exclude list
nonExcFoldersRoot = allFoldersRoot(~ismember(allFoldersRoot,exclude));

%initialize folderPaths
folderPaths = {};

%loop through each folder
for folderInd = 1:length(nonExcFoldersRoot)
    
    %change to folder
    cd(nonExcFoldersRoot{folderInd})
    
    %get list of date folders
    dateFolders = dir2cell();
    dateFolders = dateFolders(~ismember(dateFolders,{'.','..'})); %exclude navigation parameters
    dateFolders = dateFolders(cellfun(@isempty,strfind(dateFolders,'exclude'))); %exclude any containing exclude
    
    %loop through each date folder
    for dateInd = 1:length(dateFolders)
        
        %get list of files
        fileList = dir2cell(dateFolders{dateInd});
        
        %get number of unprocessed files
        nUnprocessed = sum(~cellfun(@isempty,regexp(fileList,unProcString)));
        
        %get number of processed files
        nProcessed = sum(~cellfun(@isempty,regexp(fileList,procString)));
        
        %check if twice as many processed as unprocessd
        if nProcessed == 2*nUnprocessed
            continue; %skip to next date
        else
            folderPaths = cat(1,folderPaths,{sprintf('%s%s%s%s',rootFolder,...
                filesep,nonExcFoldersRoot{folderInd},filesep,dateFolders{dateInd})});
        end
        
        if singleEntry && length(folderPaths) == 1;
            cd(origDir);
            return;
        end           
        
    end
    
    %change back to root folder
    cd(rootFolder);
end

%change back to original directory
cd(origDir);

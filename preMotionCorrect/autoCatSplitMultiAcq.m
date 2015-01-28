function [tiffNames, tiffPaths, tiffFiles] = autoCatSplitMultiAcq(folder,...
    nPlanes,nExtraPlanes,nFramesNorm)
%autoCatMultiAcq.m Automatically searches for multiple acquisitions and
%concatenates proper planes together into single large file saved in
%bigtiff format
%
%INPUTS
%folder - folder to search for multiple acquisitions
%nPlanes - number of actual planes
%nExtraPlanes - number of extra (flyback planes)
%nFramesNorm - number of frames over which to normalize intensity 
%
%OUTPUTS
%tiffNames - 1 x nFiles cell array containing the names of the new tiffs
%tiffPaths - 1 x nFiles cell array containing the paths of the new tiffs
%tiffFiles - 1 x nFiles cell array containing the full path and name of the
%   new tiffs
%
%ASM 10/13

%set default nPlanes and nExtraPlanes
DEFAULTNFRAMESNORM = 300;
DEFAULTNEXTRA = 1;
DEFAULTNPLANES = 4;
if nargin < 4; nFramesNorm = DEFAULTNFRAMESNORM; end;
if nargin < 3; nExtraPlanes = DEFAULTNEXTRA; end;
if nargin < 2; nPlanes = DEFAULTNPLANES; end;

%get folder if not given
if nargin < 1 || isempty(folder)
    %get folder
    baseDir = 'D:\DATA\2P Data\ResScan';
    folder = uigetdir(baseDir);
    if folder == 0
        return;
    end
end

%change to folder
origDir = cd(folder);

%get list of files in folder
fileList = dir('*.tif');
fileList = {fileList(:).name};

%break apart folder name
folderParts = explode(folder,filesep);
mouseName = folderParts{end - 1};
date = folderParts{end};

%filter out other files
fileList = fileList(cell2mat(cellfun(@(x) ~isempty(regexp(x,...
    [mouseName,'_\d\d\d_\d\d\d.tif'], 'once')),fileList,'UniformOutput',false)));

%add folder to each file
fullFileList = cellfun(@(x) fullfile(folder,x),fileList,'UniformOutput',false);
nFiles = length(fullFileList);

%get number of stacks
stackNums = regexp(fileList,'(?<=\w*_)\d\d\d(?=_)','match'); 
stackNums = stackNums(cell2mat(cellfun(@(x) ~isempty(x),stackNums,'UniformOutput',false))); %remove empty cells
stackNums = cellfun(@(x) x{1},stackNums,'UniformOutput',false); %open each cell
[uniqueStacks,~,fileIDs] = unique(stackNums);
nStacks = length(uniqueStacks);

%find last file of each acq
acqChanges = [find(diff(fileIDs) == 1)' length(fileIDs)];


%create file names
for i = 1:nPlanes
    tiffPaths{i} = folder;
    tiffNames{i} = sprintf('%s_%s_Plane%03d_cat.tif',mouseName,date,i);
    tiffFiles{i} = fullfile(tiffPaths{i},tiffNames{i});
    
    %delete tiffFile if it exists
    if exist(tiffFiles{i},'file')
        delete(tiffFiles{i});
    end
end

%initialize catTiffs
catTiffs = [];
meanLast = 0;
acqInd = 1;

%initialize waitbar
hWait = waitbar(0,sprintf('Loading tif %d out of %d',0,nFiles));
set(findall(hWait,'type','text'),'Interpreter','none');

%set up options for saving
options.comp = 'no';
options.color = false;
options.message = false;
options.ask = false;
options.append = true;

%load in each file
for i = 1:nFiles
    
    %update waitbar
    waitbar(i/nFiles,hWait,sprintf('Loading %s...File %d out of %d',...
        fileList{i},i,nFiles));
    
    %load
    tempTiff = loadtiffAM(fullFileList{i});
    
    %concatenate
    catTiffs = cat(3,catTiffs,tempTiff);
    
    %check if end of acquisition
    if ismember(i,acqChanges)
        
        %split and save
        meanLast = splitAndSave(catTiffs,tiffFiles,hWait,nPlanes,...
            nExtraPlanes,options,acqInd,meanLast,nFramesNorm,i/nFiles);
        
        %clear catTiffs
        clear catTiffs;
        catTiffs = [];
        
        %increment acqInd
        acqInd = acqInd + 1;
    end
end

%delete waitbar
delete(hWait);

end
function meanLastNew = splitAndSave(catTiffs,tiffFiles,hWait,nPlanes,...
        nExtraPlanes,options,ind,meanLastPrior,nFramesNorm,waitbarState)

%initialize splitting variables
nFrames = size(catTiffs,3);
frameStep = nPlanes + nExtraPlanes;
meanLastNew = zeros(1,nPlanes);

%split up files
for i = 1:nPlanes
    
    %update waitbar
    waitbar(waitbarState,hWait,sprintf('Splitting acquisition %d, plane %d out of %d',...
        ind,i,nPlanes));
    
    %get frames to keep
    framesToKeep = i:frameStep:nFrames;
    
    %split
    splitPlanes = catTiffs(:,:,framesToKeep);
    
    %normalize mean activity
    if ind > 1
        %get mean pixel intensity acquisition j+1
        meanFirst = median(mean(mean(splitPlanes(:,:,1:nFramesNorm))));
        
        %get intensity ratio
        intensRatio = meanLastPrior(i)/meanFirst;
        
        %normalizeFrames
        splitPlanes = splitPlanes*intensRatio;
        
        %get new meanlast
        meanLastNew(i) = median(mean(mean(splitPlanes(:,:,...
            end-nFramesNorm+1:end))));
   
    else
        %set meanLastNew for subsequent acquisitions
        meanLastNew(i) = median(mean(mean(splitPlanes(:,:,...
            end-nFramesNorm+1:end))));
    end
    
    %update waitbar
    waitbar(waitbarState,hWait,sprintf('Saving acquisition %d plane %d out of %d',...
        ind,i,nPlanes));
    
    %save
    saveasbigtiff(splitPlanes,tiffFiles{i},options);
    
end
end

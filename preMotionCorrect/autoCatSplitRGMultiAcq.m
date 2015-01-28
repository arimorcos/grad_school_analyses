function [tiffNames, tiffPaths, tiffFiles,acqInds] = autoCatSplitRGMultiAcq(folder,...
    nPlanes,nExtraPlanes,nFramesNorm,channelLabels)
%autoCatMultiAcq.m Automatically searches for multiple acquisitions and
%concatenates proper planes together into single large file saved in
%bigtiff format
%
%INPUTS
%folder - folder to search for multiple acquisitions
%nPlanes - number of actual planes
%nExtraPlanes - number of extra (flyback planes)
%nFramesNorm - number of frames over which to normalize intensity
%channelLabels - labels for channels. Defaults to {'green','red'};
%
%OUTPUTS
%tiffNames - nChannels x nFiles cell array containing the names of the new tiffs
%tiffPaths - nChannels x nFiles cell array containing the paths of the new tiffs
%tiffFiles - nChannels x nFiles cell array containing the full path and name of the
%   new tiffs
%acqInds - 1 x nOutputFrames array of acquisition indices
%
%ASM 10/13

%set default nPlanes and nExtraPlanes
DEFAULTCHANNELLABELS = {'green','red'};
DEFAULTNFRAMESNORM = 300;
DEFAULTNEXTRA = 1;
DEFAULTNPLANES = 4;
if nargin < 5 || isempty(channelLabels); channelLabels = DEFAULTCHANNELLABELS; end;
if nargin < 4 || isempty(nFramesNorm); nFramesNorm = DEFAULTNFRAMESNORM; end;
if nargin < 3 || isempty(nExtraPlanes); nExtraPlanes = DEFAULTNEXTRA; end;
if nargin < 2 || isempty(nPlanes); nPlanes = DEFAULTNPLANES; end;

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
    [mouseName,'.*_\d\d\d_\d\d\d.tif'], 'once')),fileList,'UniformOutput',false)));

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

%get nChannels
nChannels = length(channelLabels);

%create file names
for channelInd = 1:nChannels
    if ~isempty(channelLabels{channelInd})   
        channelLabels{channelInd} = [channelLabels{channelInd},'_'];
    end
    for fileInd = 1:nPlanes
        tiffPaths{channelInd,fileInd} = folder;
        tiffNames{channelInd,fileInd} = sprintf('%s_%s_%sPlane%03d_cat.tif',mouseName,date,channelLabels{channelInd},fileInd);
        tiffFiles{channelInd,fileInd} = fullfile(tiffPaths{channelInd,fileInd},tiffNames{channelInd,fileInd});

        %delete tiffFile if it exists
        if exist(tiffFiles{channelInd,fileInd},'file')
            delete(tiffFiles{channelInd,fileInd});
        end
    end
end

%initialize catTiffs
catTiffs = cell(1,nChannels);
meanLast = zeros(1,nChannels);
acqInd = 1;
acqInds = [];

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
for fileInd = 1:nFiles
    
    %update waitbar
    waitbar(fileInd/nFiles,hWait,sprintf('Loading %s...File %d out of %d',...
        fileList{fileInd},fileInd,nFiles));
    
    %load
    tempTiff = loadtiffAM(fullFileList{fileInd});
    
    %split into channels
    tempChannelTiffs = cell(1,nChannels);
    for channelInd = 1:nChannels
        framesToKeep = channelInd:nChannels:size(tempTiff,3);
        tempChannelTiffs{channelInd} = tempTiff(:,:,framesToKeep);
        
        %concatenate
        catTiffs{channelInd} = cat(3,catTiffs{channelInd},tempChannelTiffs{channelInd});
        
        %add in to acqInds
        acqInds(length(acqInds)+1:length(acqInds)+length(framesToKeep)) = acqInd;
        
        %check if end of acquisition
        if ismember(fileInd,acqChanges)
            
            %split and save
            meanLast(channelInd) = splitAndSave(catTiffs{channelInd},tiffFiles(channelInd,:),...
                hWait,nPlanes,nExtraPlanes,options,acqInd,meanLast(channelInd),...
                nFramesNorm,fileInd/nFiles,channelInd);
            
            if channelInd == nChannels
                %clear catTiffs
                clear catTiffs;
                catTiffs = cell(1,nChannels);

                %increment acqInd
                acqInd = acqInd + 1;
            end
        end
    end
    
    
end

%delete waitbar
delete(hWait);

end

function meanLastNew = splitAndSave(catTiffs,tiffFiles,hWait,nPlanes,...
    nExtraPlanes,options,ind,meanLastPrior,nFramesNorm,waitbarState,channelInd)

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
    waitbar(waitbarState,hWait,sprintf('Saving acquisition %d channel %d plane %d out of %d',...
        ind,i,nPlanes,channelInd));
    
    %save
    saveasbigtiff(splitPlanes,tiffFiles{i},options);
    
end
end

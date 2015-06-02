function autoPostAcq2P(folderPath,ask,vCellFile)
%autoPostICA.m Function to perform all postICA processing in the following
%order:
%   1) Get dF/F traces
%   2) Line up frames with virmen
%   3) Load data and dataCell from virmen
%   4) Add imaging field into dataCell
%   5) save binned data array and dF/F traces divided by trial into
%       dataCell
%
%INPUTS
%ask - should ask for virmen and sync/pFile or automatically locate. If empty,
%       false
%vCellFile - path and file name for virmen dataCell file

%%%%%%%%%%%%%%%%%%% CONSTANTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vPath = 'D:\Data\Ari\';
pPath = 'Z:\HarveyLab\Ari\2P Data\ResScan\PClamp Files';
syncPath = 'Z:\HarveyLab\Ari\2P Data\ResScan\Sync';
defaultImPath = 'Z:\HarveyLab\Ari\2P Data\ResScan';

window = 60;
percentileVal = 15;

if nargin < 2 || isempty(ask) %should ask
    ask = false;
end

if nargin < 1 || isempty(folderPath)
    folderPath = uigetdir(defaultImPath);
end

%%%%%%%%%%%%%%%%%%%  FIND ACQ2P OBJECT %%%%%%%%%%%

fprintf('Loading acq2P object...');

%get acqName
fileParts = explode(folderPath,filesep);
mouseName = fileParts{end-1};
acqDate = fileParts{end};
acqName = sprintf('%s_%s',mouseName,acqDate);
acqPath = sprintf('%s%s%s_acq_local.mat',folderPath,filesep,acqName);

%load in acq2P object
loadVar = load(acqPath);
acq = loadVar.(acqName);
clear('loadVar');

fprintf('Complete\n');

%%%%%%%%%%%%%%%%%%% GET BASIC ACQUISITION INFORMATION %%%%%%%%%%%%%%%%

%get nFrames
if isfield(acq.derivedData,'size')
    nFrames = sum(cat(1,acq.derivedData.size));
elseif isfield(acq.correctedMovies.slice(1).channel(1),'size')
    nFrames = sum(cat(1,acq.correctedMovies.slice(1).channel(1).size));
else
    error('Can''t find size field');
end
nFrames = nFrames(3);

sImage = acq.derivedData(1).SIData;
if isfield(sImage,'SI4')
    sImage = sImage.SI4;
    sImage.version = 'SI4';
    if sImage.fastZEnable %if fastZ
        nExtraPlanes = sImage.fastZNumDiscardFrames;
        nPlanes = sImage.stackNumSlices;
    else
        nPlanes = 1;
        nExtraPlanes = 0;
    end
    frameRate = sImage.scanFrameRate;
    tiffBase = sImage.loggingFileStem;
    
elseif isfield(sImage,'SI5')
    sImage = sImage.SI5;
    sImage.version = 'SI5';
    if sImage.fastZEnable %if fastZ
        nExtraPlanes = sImage.fastZNumDiscardFrames;
        nPlanes = sImage.stackNumSlices;
    else
        nPlanes = 1;
        nExtraPlanes = 0;
    end
    frameRate = 1/sImage.scanFramePeriod;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%% FIND VIRMEN FILE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%find virmen file
if ~exist('vCellFile','var') || isempty(vCellFile)
    if ask %if should ask
        
        %get vFile
        if exist(fullfile(vPath,'Current Mice',mouseName),'dir') %check if directory is in current, archived or neither
            origDir = cd(fullfile(vPath,'Current Mice',mouseName)); %change to virmen directory
        elseif exist(fullfile(vPath,'Archived Mice',mouseName),'dir')
            origDir = cd(fullfile(vPath,'Archived Mice',mouseName)); %change to virmen directory
        else
            origDir = cd('D:\Data\Ari\');
        end
        [vName,vPath] = uigetfile('*_Cell.mat');
        if vName == 0 %if canceled
            return;
        end
        vCellFile = fullfile(vPath,vName);
        vMatFile = regexp(vCellFile,'_Cell','split');
        vMatFile = [vMatFile{1} vMatFile{2}];
        cd(origDir);
        
    else %otherwise automatically generate file names
        if exist(fullfile(vPath,'Current Mice',mouseName),'dir') %check if directory is in current, archived or neither
            currStr = 'Current Mice';
        elseif exist(fullfile(vPath,'Archived Mice',mouseName),'dir')
            currStr = 'Archived Mice';
        end
        vCellSearchStr = fullfile(vPath,currStr,mouseName,...
            [mouseName,'_',acqDate,'_Cell*.mat']);
        
        %get number of files which match search string
        vFileSearch = dir(vCellSearchStr);
        if length(vFileSearch) > 1 %if more than one file from that day
            [vName,vPath] = uigetfile(vCellSearchStr);
            vCellFile = fullfile(vPath,vName);
        else
            vCellFile = fullfile(vPath,currStr,mouseName,...
            [mouseName,'_',acqDate,'_Cell.mat']);
        end
        vMatFile = regexp(vCellFile,'_Cell','split');
        vMatFile = [vMatFile{1} vMatFile{2}];
    end
else
    vMatFile = regexp(vCellFile,'_Cell','split');
    vMatFile = [vMatFile{1} vMatFile{2}];
end


%%%%%%%%%%%%%%%%%%%%%%%%%% GET SYNC DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Getting sync data...');

pFolderPath = fullfile(pPath,mouseName,acqDate);
syncFolderPath = fullfile(syncPath,mouseName,acqDate);
if isdir(pFolderPath) %if PClamp folder exists
    %sync up with pFiles
    planeItRanges = getMultiPFileNew(nFrames,nPlanes,nExtraPlanes,...
        pPath,mouseName,acqDate,acqName);
elseif isdir(syncFolderPath) %if sync folder exists
    planeItRanges = getMultiSyncFile(nFrames,nPlanes,nExtraPlanes,...
        syncPath,mouseName,acqDate,acqName);
else
    error('No synchronization folder found');
end
if any(cellfun(@isempty,planeItRanges)); return; end

fprintf('Complete\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%% LOAD IN BEHAVIOR DATA AND PRE-PROCESS %%%%%%%%

fprintf('Loading behavioral data...');

%load data and dataCell
load(vMatFile,'data');
load(vCellFile,'dataCell');

%parse data array
dataCell = parseDataArray(dataCell,data);

%reset dataCell
dataCell = resetDataCellImaging(dataCell);

%add sImage
dataCell = addSImageDataCell(dataCell,sImage);

fprintf('Complete\n');

%%%%%%%%%%%%%%%%%%%%%%% EXTRACT TRACES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for planeInd = 1:nPlanes %for each plane
       
    %get dF/F traces
    fprintf('Extracting traces for plane %d...',planeInd);
    extractedTracePath = sprintf('%s%s%s_extractedTraces.mat',folderPath,filesep,acqName);
    [dFF, roiGroups] = extractTraces(acq,extractedTracePath,'baselinewin',window,...
        'baselineperc',percentileVal);
    fprintf('Complete\n');

    %get minFrames
    minDuration = datevec(min(getCellVals(dataCell,'time.stop') -...
        getCellVals(dataCell,'time.start'))); %get shortest trial
    minDuration = 3600*minDuration(4) + 60*minDuration(5) + minDuration(6); %convert to seconds
    minFrames = floor(0.9*minDuration*frameRate); %figure out minimum number of frames for a given trial

    %subdivide data array by frame
    fprintf('Subsetting data into frames...');
    [dataFrames,trialIDs] = subDataByFrame(data,planeItRanges{planeInd},minFrames);
    fprintf('Complete\n');
    
    %add imaging field to dataCell if necessary
    dataCell = addImagingDataField(dataCell);

    %copy dFF, PCA, and dataFrames to dataCell
    dataCell = copyFDataToCell(dataCell,trialIDs,planeInd,dataFrames,dFF,...
        roiGroups);
end

%save dataCell
fprintf('Saving dataCell...');
save(vCellFile,'dataCell');
fprintf('Complete\n');

end



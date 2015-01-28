function autoPostICA(folderPath,fileStr,ask,vCellFile)
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
%ask - should ask for virmen and pFile or automatically locate. If empty,
%       false
%tiff - optional path and file name for motionCorrected tiff. If empty,
%   asks for tiff file
%vCellFile - path and file name for virmen dataCell file

%%%%%%%%%%%%%%%%%%% CONSTANTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vPath = 'D:\Data\Ari\';
iPath = 'W:\ResScan';
pPath = 'K:\Data\2P Data\ResScan\PClamp Files\';

% %ask for necessary variables
% options.WindowStyle = 'normal';
% options.Resize = 'on';
% paramNames = {'Frame rate (Hz)','Baseline window (s)',...
%     'Baseline percentile','nPlanes','nExtraPlanes'};
% postICAParam = inputdlg(paramNames,'Enter Post ICA Parameters',...
%     repmat([1 60],length(paramNames),1),{'5.67','20','8','4','1'},options);
% 
% %convert to double
% frameRate = str2double(postICAParam{1});
% window = str2double(postICAParam{2});
% percentileVal = str2double(postICAParam{3});
% nPlanes = str2double(postICAParam{4});
% nExtraPlanes = str2double(postICAParam{5});

%%%%%%%%%%%%%%%%%%%  GET FILES TO PROCESS OR AUTOGENERATE NAMES %%%%%%%%%%%

%get list of tiff files
fileList = getMatchingFileList(folderPath,fileStr);

%get basic information 
[~,sImage] = loadtiffAM(fileList{1},1);
if sImage.fastZEnable %if fastZ
    nExtraPlanes = sImage.fastZNumDiscardFrames;
    nPlanes = sImage.stackNumSlices;
else
    nPlanes = 1;
    nExtraPlanes = 0;
end
frameRate = sImage.scanFrameRate;
window = 20;
percentileVal = 8;
tiffBase = sImage.loggingFileStem;
channelNames = sImage.channelsMergeColor(sImage.channelsSave);
nChannels = length(channelNames);

%get nFrames
% nFrames = getNPagesMultiFile(folderPath,fileStr);

%break apart filePath
tifParts = explode(folderPath,filesep);

%get mouse name
mouseName = tifParts{3};

%get date
date = datestr(datenum(sImage.triggerClockTimeFirst,'dd-mm-yyyy HH:MM:SS.FFF'),'yymmdd');

if nargin < 3 || isempty(ask) %should ask
    ask = false;
end

%find virmen file
if nargin < 4 || isempty(vCellFile)
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
            [mouseName,'_',date,'_Cell*.mat']);
        
        %get number of files which match search string
        vFileSearch = dir(vCellSearchStr);
        if length(vFileSearch) > 1 %if more than one file from that day
            [vName,vPath] = uigetfile(vFileSearchStr);
            vCellFile = fullfile(vPath,vName);
        else
            vCellFile = fullfile(vPath,currStr,mouseName,...
            [mouseName,'_',date,'_Cell.mat']);
        end
        vMatFile = regexp(vCellFile,'_Cell','split');
        vMatFile = [vMatFile{1} vMatFile{2}];
    end
else
    vMatFile = regexp(vCellFile,'_Cell','split');
    vMatFile = [vMatFile{1} vMatFile{2}];
end


%%%%%%%%%%%%%%%%%%%%% PROCESS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%sync up with pFiles
planeItRanges = getMultiPFile(folderPath,fileStr,nPlanes,nExtraPlanes,nChannels,...
    pPath,mouseName,date,tiffBase);
if any(cellfun(@isempty,planeItRanges)); return; end

%load data and dataCell
load(vMatFile,'data');
load(vCellFile,'dataCell');

%parse data array
dataCell = parseDataArray(dataCell,data);

%reset dataCell
dataCell = resetDataCellImaging(dataCell);

%add sImage
dataCell = addSImageDataCell(dataCell,sImage);

for planeInd = 1:nPlanes %for each tiffFile
    
    %load filters
    filterStr = sprintf('%s%s%s_Plane%03d_green_manualROI.mat',folderPath,filesep,tiffBase,planeInd);
    load(filterStr,'ROIs');
    
    %remove overlapping regions
    ROIs = removeOverlappingRegions(ROIs);
    
    %get dF/F traces
    [dFFTraces,dGRTraces,meanG,meanR] = getTracesMultiTiff(folderPath,fileStr,...
        ROIs,percentileVal,window,frameRate);

    %get PCA
    [dFFPCA,dFFVar] = getNeuronPCA(dFFTraces);
    [dGRPCA,dGRVar] = getNeuronPCA(dGRTraces);

    %get minFrames
    minDuration = datevec(min(getCellVals(dataCell,'time.stop') -...
        getCellVals(dataCell,'time.start'))); %get shortest trial
    minDuration = 3600*minDuration(4) + 60*minDuration(5) + minDuration(6); %convert to seconds
    minFrames = floor(0.9*minDuration*frameRate); %figure out minimum number of frames for a given trial

    %subdivide data array by frame
    [dataFrames,trialIDs] = subDataByFrame(data,planeItRanges{planeInd},minFrames);

    %add imaging field to dataCell if necessary
    dataCell = addImagingDataField(dataCell);

    %copy dFF, PCA, and dataFrames to dataCell
    dataCell = copyFDataToCell(dataCell,trialIDs,planeInd,dataFrames,dFFTraces,...
        dGRTraces,meanG,meanR,dFFPCA,dFFVar,dGRPCA,dGRVar,);
end

%save dataCell
save(vCellFile,'dataCell');

end



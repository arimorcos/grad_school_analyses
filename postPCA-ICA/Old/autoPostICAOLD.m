function autoPostICAOLD(ask,tiff,vCellFile)
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

%ask for necessary variables
options.WindowStyle = 'normal';
options.Resize = 'on';
paramNames = {'Frame rate (Hz)','Baseline window (s)',...
    'Baseline percentile','nPlanes','nExtraPlanes'};
postICAParam = inputdlg(paramNames,'Enter Post ICA Parameters',...
    repmat([1 60],length(paramNames),1),{'5.67','20','8','4','1'},options);

%convert to double
frameRate = str2double(postICAParam{1});
window = str2double(postICAParam{2});
percentileVal = str2double(postICAParam{3});
nPlanes = str2double(postICAParam{4});
nExtraPlanes = str2double(postICAParam{5});

%%%%%%%%%%%%%%%%%%%  GET FILES TO PROCESS OR AUTOGENERATE NAMES %%%%%%%%%%%

if nargin < 2 || isempty(tiff) %tiff file
    
    %get tiff
    origDir = cd(iPath); %change to resScan dir
    [tiffName,tiffPath] = uigetfile('*.tif','Select post ICA tif');
    if tiffName == 0 %if canceled
        return;
    end
    tiffFile = fullfile(tiffPath,tiffName);
    tiffBase = tiffName(1:regexp(tiffName,'.tif')-1);
    cd(origDir);
end

%process tif name
    
%break apart filePath
tifParts = explode(tiffFile,filesep);

%get mouse name
mouseName = tifParts{5};

%get date
date = tifParts{6};

if nargin < 1 || isempty(ask) %should ask
    ask = false;
end

if nargin < 3 || isempty(vCellFile)
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
end


%%%%%%%%%%%%%%%%%%%%% PROCESS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%sync up with pFiles
[planeItRanges,whichPlane] = getMultiPFile(tiffBase,tiffFile,nPlanes,nExtraPlanes,...
    pPath,mouseName,date);

%load data and dataCell
load(vMatFile,'data');
load(vCellFile,'dataCell');

%ask if multiple tiff files
questAns = questdlg('Are there multiple tiff planes?','Multiple planes?','Yes',...
    'No','Yes');
if strcmp(questAns,'Yes') %if yes
    [~,~,tiffFiles] = getTIFFNames(tiffPath);
else
    tiffFiles{1} = tiffFile;
end

%reset dataCell
dataCell = resetDataCellImaging(dataCell);

for i = 1:length(tiffFiles) %for each tiffFile
    %get whichPlane
    whichPlane = str2double(regexp(tiffFiles{i},'(?<=Plane)\d\d\d','match'));
    
    %get dF/F traces
    [dFFTraces] = postICAProcessing(true,tiffFiles{i},percentileVal,window,frameRate);

    %get PCA
    [PCA,variance] = getNeuronPCA(dFFTraces);

    %get minFrames
    minDuration = datevec(min(getCellVals(dataCell,'time.stop') -...
        getCellVals(dataCell,'time.start')));
    minDuration = 3600*minDuration(4) + 60*minDuration(5) + minDuration(6);
    minFrames = floor(0.9*minDuration*frameRate);

    %subdivide data array by frame
    [dataFrames,trialIDs] = subDataByFrame(data,planeItRanges{whichPlane},minFrames);

    %add imaging field to dataCell if necessary
    dataCell = addImagingDataField(dataCell);

    %copy dFF, PCA, and dataFrames to dataCell
    dataCell = copyDFFToDataCell(dataCell,dataFrames,dFFTraces,PCA,variance,...
        trialIDs,whichPlane);
end

%save dataCell
save(vCellFile,'dataCell');

end



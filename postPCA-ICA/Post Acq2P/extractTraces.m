function [dFF,roiGroups] = extractTraces(acq,traceFile,varargin)
%extractTraces.m Extracts traces from object and performs moving baseline
%correction 
%
%INPUTS
%acq - acq2P object
%traceFile - path to traces file
%
%OPTIONAL INPUTS
%baselineWin - baseline window in seconds. Default is 60.
%baselinePerc - baseline percentile. Default is 15.
%forceOverwrite - force overwrite of dFF if already exist. Default is false
%
%OUTPUTS
%dFF - nCells x n%dF/F
%
%
%ASM 12/14

%process varargin
baselineWin = 60; %baseline window in seconds
baselinePerc = 15; %baseline percentile 
ignoreGroup = 9;
forceOverwrite = false; %force overwrite of dF/F

if nargin > 2 || ~isempty(varargin)
    if isodd(length(varargin))
        error('Must provide a name and value for each argument');
    end
    for argInd = 1:2:length(varargin) %for each argument
        switch lower(varargin{argInd})
            case 'baselinewin'
                baselineWin = varargin{argInd+1};
            case 'baselineperc'
                baselinePerc = varargin{argInd+1};
            case 'forceoverwrite'
                forceOverwrite = varargin{argInd+1};
            case 'ignoregroup'
                ignoreGroup = varargin{argInd+1};
        end
    end
end

%argument checking
if nargin < 1 || isempty(acq)
    [acqFileName,acqFilePath] = uigetfile('Z:\HarveyLab\Ari\2P Data\ResScan');
    acqFile = fullfile(acqFilePath,acqFileName);
    loadVar = load(acqFile);
    varNames = fieldnames(loadVar);
    acq = loadVar.(varNames{1});
end


if nargin < 2 || isempty(traceFile) || ~exist(traceFile,'file') || forceOverwrite
    %look for trace file
    traceFile = fullfile(acq.defaultDir,[acq.acqName,'_extractedTraces.mat']);
    if ~exist(traceFile,'file') || forceOverwrite
        [traces, rawF, roi, ~] = getAcq2PRawTraces(acq,ignoreGroup);
        if ~exist(traceFile,'file')
            error('Created trace file, but can''t find');
        end
    end
end
%create matfile
traceMatFile = matfile(traceFile,'Writable',true);


fprintf('Loading roi info...');
if ~exist('roi','var')
    roi = traceMatFile.roi;
end
fprintf('Complete\n');

%get roiGroups
roiGroups = [roi.group];

%check if dFF already exists
if any(strcmp(who(traceMatFile),'dFF')) && ~forceOverwrite
    fprintf('dF/F trace already exists. Loading...');
    dFF = traceMatFile.dFF;
    fprintf('Complete\n');
    return;
end

%load traces
fprintf('Loading traces...')
if ~exist('rawF','var')
    rawF = traceMatFile.rawF;
end
if ~exist('traces','var')
    traces = traceMatFile.traces;
end
fprintf('Complete\n');

% %get framerate
% if isfield(acq.derivedData(1).SIData,'SI5') %if scanimage 5
%     frameRate = 1/acq.derivedData(1).SIData.SI5.scanFramePeriod;
% elseif isfield(acq.derivedData(1).SIData,'SI4') %if scanimage 4
%     frameRate = acq.derivedData(1).SIData.SI4.scanFrameRate;
% end
% 
% %get number of frames in baseline window
% winFrames = round(baselineWin*frameRate);
% 
% %get moving percentile
% fprintf('Extracting baseline...\n');
% baselineF = getMovingPercentile(rawF,baselinePerc,winFrames);
% fprintf('Extracting baseline...Complete\n');
% 
% %calculate %dF/F
% dFF = 100*(traces - baselineF)./baselineF;

fprintf('Getting dF/F...');
dFF = dFcalc(traces,rawF,'linear');
fprintf('Complete\n');

%save in extractedTraces file
fprintf('Saving dF/F...');
traceMatFile.dFF = dFF;
fprintf('Complete\n');
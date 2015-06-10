function handles = plotMultipleDeltaPLeftFromFolder(folder,fileStr,version)
%plotMultipleDeltaPLeftFromFolder.m Plots multiple delta pLeft from folder
%
%INPUTS
%folder - path to folder
%fileStr - string to match files to
%
%OUTPUTS
%handles - structure of handles
%
%ASM 4/15

showLegend = true;

if nargin < 3 || isempty(version)
    version = 'epoch';
end

%get list of files in folder 
[allNames, ~, ~, ~, isDirs] = dir2cell(folder);
files = allNames(~isDirs);

%match string 
matchFiles = files(~cellfun(@isempty,regexp(files,fileStr)));
nFiles = length(matchFiles);

%loop through each file and create array 
confInt = cell(nFiles,1);
deltaPLeft = cell(nFiles,1);
netEvidence = cell(nFiles,1);
segWeights = cell(nFiles,1);
for fileInd = 1:nFiles
    currFileData = load(fullfile(folder,matchFiles{fileInd}));
    confInt{fileInd} = currFileData.confInt;
    netEvidence{fileInd} = currFileData.netEvidence;
    deltaPLeft{fileInd} = currFileData.deltaPLeft;
    segWeights{fileInd} = currFileData.segWeights;
end

%% deltaPLeftVsEpoch

%plot
handles = [];
for mouseInd = 1:length(matchFiles)
    switch version
        case 'epoch'
            handles = plotDeltaPLeftVsEpoch(deltaPLeft{mouseInd},handles);
        case 'netEv'
            handles = plotDeltaPLeftVsNetEv(deltaPLeft{mouseInd},netEvidence{mouseInd},...
                [],false,handles);
        otherwise 
            error('Can''t interpret %s',version);
    end
end

%add legend
if showLegend
    legend(handles.errH,strrep(matchFiles,'_','\_'),'Location','BestOutside');
end
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

showLegend = false;

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
out = cell(nFiles,1);
for fileInd = 1:nFiles
    currFileData = load(fullfile(folder,matchFiles{fileInd}));
    out{fileInd} = currFileData.out;
end

%% deltaPLeftVsEpoch

%plot
handles = [];
for mouseInd = 1:length(matchFiles)
    switch version
        case 'epoch'
            handles = plotDeltaPLeftVsEpoch(out{mouseInd}.deltaPLeft,handles);
        case 'netEv'
            handles = plotDeltaPLeftVsNetEv(out{mouseInd}.deltaPLeft,out{mouseInd}.netEv,...
                [],true,handles);
        otherwise 
            error('Can''t interpret %s',version);
    end
end

%add legend
if showLegend
    legend(handles.errH,strrep(matchFiles,'_','\_'),'Location','BestOutside');
end
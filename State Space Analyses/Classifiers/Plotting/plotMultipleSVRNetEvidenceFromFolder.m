function handles = plotMultipleSVRNetEvidenceFromFolder(folder,fileStr)
%plotMultipleSVRNetEvidenceFromFolder.m Plots multiple classifiers based on a
%specific folder path
%
%INPUTS
%folder - path to folder
%fileStr - string to match files to
%
%OUTPUTS
%handles - structure of handles
%
%ASM 4/15


%get list of files in folder
[allNames, ~, ~, ~, isDirs] = dir2cell(folder);
files = allNames(~isDirs);

%match string
matchFiles = files(~cellfun(@isempty,regexp(files,fileStr)));
if isempty(matchFiles)
    warning('No files match');
    return;
end

%loop through each file and create array
allClassOut = cell(length(matchFiles),1);
for fileInd = 1:length(matchFiles)
    currFileData = load(fullfile(folder,matchFiles{fileInd}));
    field = fieldnames(currFileData);
    if length(field) > 1
        allClassOut{fileInd} = currFileData.groupClassifier;
    else
        allClassOut{fileInd} = currFileData.(field{1});
    end
end

%plot
handles = [];
for mouseInd = 1:length(matchFiles)
    handles = plotSVRNetEvidence(allClassOut{mouseInd},handles);
end

%label axes
handles.ax.XLabel.FontSize = 30;
handles.ax.YLabel.FontSize = 30;
handles.ax.FontSize = 20;

%set axis to square
axis(handles.ax,'square');

%maximize
handles.fig.Units = 'normalized';
handles.fig.OuterPosition = [0 0 1 1];
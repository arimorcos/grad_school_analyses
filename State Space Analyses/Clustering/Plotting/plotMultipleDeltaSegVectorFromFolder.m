function handles = plotMultipleDeltaSegVectorFromFolder(folder,fileStr)
%plotMultipleDeltaSegVectorFromFolder.m Plots multiple classifiers based on a
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

%loop through each file and create array 
deltaSegStart = cell(length(matchFiles),1);
rOffset = cell(size(deltaSegStart));
deltaVec = cell(size(deltaSegStart));
for fileInd = 1:length(matchFiles)
    currFileData = load(fullfile(folder,matchFiles{fileInd}));
    deltaSegStart{fileInd} = currFileData.accuracy(2:end-2);
    rOffset{fileInd} = currFileData.shuffleAccuracy(:,2:end-2);
    deltaVec{fileInd} = currFileData.yPosBins(2:end-2);
end
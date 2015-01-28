function autoCatSplitMotCorr()
%autoCatSplitMotCorr.m function to concatenate, split based on planes, and
%motion correct imaging files
%
%ASM 10/13


%ask user for orchestra username and password
[motCorrInfo.userName, motCorrInfo.password] =...
    logindlg('Title','Orchestra Login Info');

%ask user for  parameters
options.WindowStyle = 'normal';
options.Resize = 'on';
paramNames = {'nPlanes','nExtraPlanes','Maximum Shift','Initial Correlation Threshold',...
    'Minimum Samples','Interpolation Level'};
motCorrParam = inputdlg(paramNames,'Enter Motion Correction Parameters',...
    repmat([1 60],length(paramNames),1),{'4','1','10','0.75','75','4'},options);

%convert parameters to motCorrInfo
motCorrParam = cellfun(@(x) str2double(x),motCorrParam,'UniformOutput',false);
[nPlanes,nExtraPlanes,motCorrInfo.maxShift,motCorrInfo.corrThresh,...
    motCorrInfo.minSamp,motCorrInfo.interpLevel] = deal(motCorrParam{:});

%get folders
baseDir = 'K:\DATA\2P Data\ResScan';
folders = getMultipleFolders(baseDir);

for i = 1:length(folders)
    %concatenate and split
    [motCorrInfo.tiffNames,motCorrInfo.tiffPaths,motCorrInfo.tiffFiles] =...
        autoCatSplitMultiAcq(folders{i},nPlanes,nExtraPlanes,300);

    %perform motion correction
    performMotCorrOnOrch(true,motCorrInfo);
end
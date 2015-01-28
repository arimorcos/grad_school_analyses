function autoCatMultiAcqMotCorr(folder)
%autoCatMultiAcqMotCorr.m Concatenates files and then performs motion
%correction
%
%ASM 10/13

if nargin < 1 || isempty(folder)
    folder = [];
end

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

%run autoCat
[motCorrInfo.tiffNames, motCorrInfo.tiffPaths, motCorrInfo.tiffFiles] =...
    autoCatMultiAcqFolders(folder);

%perform motion correction
performMotCorrOnOrch(true,motCorrInfo);
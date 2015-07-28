function [vCellFile,vMatFile] = getBehaviorPath(mouseName,date)

vPath = 'D:\Data\Ari\';
if exist(fullfile(vPath,'Current Mice',mouseName),'dir') %check if directory is in current, archived or neither
    currStr = 'Current Mice';
elseif exist(fullfile(vPath,'Archived Mice',mouseName),'dir')
    currStr = 'Archived Mice';
end
vCellSearchStr = fullfile(vPath,currStr,mouseName,...
    [mouseName,'_',date,'_Cell.mat']);

%get number of files which match search string
vFileSearch = dir(vCellSearchStr);
if length(vFileSearch) > 1 %if more than one file from that day
    [vName,vPath] = uigetfile(vCellSearchStr);
    vCellFile = fullfile(vPath,vName);
else
    vCellFile = fullfile(vPath,currStr,mouseName,...
        [mouseName,'_',date,'_Cell.mat']);
end

vMatFile = regexp(vCellFile,'_Cell','split');
vMatFile = [vMatFile{1} vMatFile{2}];
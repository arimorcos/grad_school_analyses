function [dataCell,data] = loadBehaviorData(mouseName,date)
%loadBehaviorData.m Automatically locates behavior data and loads
%
%INPUTS
%mouse - mouse name as string
%date - date as string in yymmdd format
%
%OUTPUTS
%dataCell
%
%ASM 5/14

[vCellFile,vMatFile] = getBehaviorPath(mouseName,date);

%load
load(vCellFile);
if nargout > 1
    load(vMatFile);
end
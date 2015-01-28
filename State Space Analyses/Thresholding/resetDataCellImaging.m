function dataCellNew = resetDataCellImaging(dataCell)
%resetDataCellImaging.m Strips all imaging data from dataCell
%
%INPUTS
%dataCell - dataCell containing imaging data
%
%OUTPUTS
%dataCellNew - dataCell containing no imaging data
%
%ASM 1/14

%check if any imaging data present
if ~isfield(dataCell{1},'imaging')
    dataCellNew = dataCell;
    return;
end

dataCellNew = dataCell;

%strip data
for i = 1:length(dataCellNew)
    dataCellNew{i} = rmfield(dataCellNew{i},'imaging');
end
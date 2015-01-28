function dataCell = addImagingDataField(dataCell)
%addImagingDataField.m Simply adds the .imaging field along and sets all
%dataCell{:}.imaging.imData = false
%
%INPUTS
%dataCell - cell array of data structures
%
%OUTPUTS
%dataCell - cell array of data structures with imaging field
%
%ASM 10/13

for i = 1:length(dataCell)
    if ~isfield(dataCell{i},'imaging') ||...
            (isfield(dataCell{i},'imaging') && ~isfield(dataCell{i}.imaging,'imData'))
        dataCell{i}.imaging.imData = false;
    end
end
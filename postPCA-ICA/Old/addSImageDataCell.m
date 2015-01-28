function dataCell = addSImageDataCell(dataCell,sImage)
%addSImageDataCell.m Function add sImage to each cell of dataCell
%
%INPUTS
%dataCell - dataCell
%sImage - sImage structure
%
%OUTPUTS
%dataCell - dataCell with sImage
%
%ASM 8/14

for i = 1:length(dataCell)
    dataCell{1}.sImage = sImage;
end
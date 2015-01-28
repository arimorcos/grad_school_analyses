function [height,width,nStrips] = getTiffHeightWidth(path)

%create tiff object
tiff = Tiff(path, 'r');

%get height, width and datatype
tiff.setDirectory(1);
width = tiff.getTag('ImageWidth');
height = tiff.getTag('ImageLength');

nStrips = tiff.numberOfStrips();
function [red,green] = splitRedGreen(tiff,shouldSave)
%splitRedGreen.m Splits red and green channels from tiff stack
%
%INPUTS
%tiff - file path or array
%shouldSave - should save new file
%
%OUTPUTS
%red - red channel array
%green - green channel array
%
%ASM 2/14

%determine if tiff is path or string 
if ischar(tiff)%if is path and file exists
    if exist(tiff) 
        tiffStack = loadtiffAM(tiff);
    else
        error('File not found');
    end
elseif isdouble(tiff)
    tiffStack = tiff;
end

%break up into red and green
green = tiffStack(:,:,1:2:end);
red = tiffStack(:,:,2:2:end);

%get tiff name
if shouldSave && ischar(tiff)
    [path,name,ext]= fileparts(tiff);
    newNameR = [fullfile(path,name),'_red',ext];
    newNameG = [fullfile(path,name),'_green',ext];
    saveasbigtiff(green,newNameG);
    saveasbigtiff(red,newNameR);
end
    
    
    
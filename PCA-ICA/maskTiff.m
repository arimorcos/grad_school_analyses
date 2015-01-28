function maskedTiff = maskTiff(tiff,filters)
%maskTiff.m Masks tiff with filters
%
%INPUTS
%tiff - m x n x nFrames tiff stack
%filters - m x n binary filters
%
%OUTPUTS
%maskedTiff - m x n x nFrames tiff with all filter regions masked
%
%ASM 3/14

%copy tiff
maskedTiff = tiff;

%convert to column vector
filters = filters(:);

%reshape maskedTiff
maskedTiff = reshape(maskedTiff,size(filters,1),size(tiff,3));

%set to 0 
maskedTiff(filters==1,:) = 0;

%reshape back to movie
maskedTiff = reshape(maskedTiff,size(tiff));
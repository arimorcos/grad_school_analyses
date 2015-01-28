function [shiftTIFF] = affineAdjustTIFF(tiff,xShifts,yShifts,segPos)
%affineAdjustTIFF.m function to create new tiff with x/yShifts
%
%INPUTS
%tiff - tiff stack to be adjusted
%xShifts - 1 x nFrames vector of x shift values
%yShifts - 1 x nFrames vector of y shift values
%
%OUTPUTS
%shiftTiff - shifted tiff stack
%
%ASM 5/14 based off Affine_Transform_Frames SC

%save the size of the movie
[height,width,nFrames] = size(tiff);

yOff = segPos(:,2) + floor(segPos(:,4)/2);
xOff = segPos(:,1) + floor(segPos(:,3)/2);
rpts = [xOff, yOff];
R=imref2d([height,width]);

% Apply affine transform
parfor frame = 1:nFrames
    xframe = xShifts(:,frame) + xOff;
    yframe = yShifts(:,frame) + yOff;
    fpts = [xframe, yframe];
    tform=fitgeotrans(fpts,rpts,'affine');
    shiftTIFF(:,:,frame)=imwarp(tiff(:,:,frame),tform,'OutputView',R,'FillValues',nan);
end
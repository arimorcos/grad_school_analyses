background = imopen(red,strel('disk',15));

%subtract background
backSub = red - background;
% adjustSub = imadjust(backSub,[],[],200);
%binarize 
% binIm = backSub;
% thresh = 40*graythresh(backSub);
% binIm(binIm <= thresh) = 0;
% binIm(binIm > thresh) = 1;
binIm = adaptivethreshold(backSub,60,-0.005);

%remove small objects
binIm = bwareaopen(binIm,40);

%display
imagesc(binIm);
colormap(gray);
axis square;
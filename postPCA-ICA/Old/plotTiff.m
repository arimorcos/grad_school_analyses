function plotTiff(image,newFig)
if nargin < 2
    newFig = false;
end
if newFig
    figure;
end
imagesc(image);
colormap(gray);
axis image;
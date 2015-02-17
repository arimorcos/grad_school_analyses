function plotROIs(tiff,roi)
%plotROIs.m plots the number of each roi at the centroid 
%

plotTiff(mean(tiff,3));

for i = 1:length(roi)
%     [row,col] = ind2sub(size(tiff(:,:,1)),median(roi(i).indBody));
    %create image matrix 
    roiImg = zeros(size(tiff(:,:,1)));
    roiImg(roi(i).indBody) = 1;
    
    %get centroid 
    stats = regionprops(roiImg,'Centroid');
    
    text(stats.Centroid(1),stats.Centroid(2),sprintf('%d',i),'Color','w');
end
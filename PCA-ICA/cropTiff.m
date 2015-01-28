function cropTiff(tiffPath,rangeFile)
%opens a gui to crop a tiff


%create projection string
[path,name,ext] = fileparts(tiffPath);
projPath = [fullfile(path,name),'_zProj',ext];

%load projection
projection = loadtiffAM(projPath);

if nargin < 2 || isempty(rangeFile)
    %display projection
    cropFig = figure;
    imagesc(projection.^.5);
    colormap(gray);
    axis square;

    %get corners
    corners = ginput(2);

    %round corners
    corners = round(corners);

    %get range
    range = [max(1,corners(1,2)) min(corners(2,2),size(projection,1));
             max(1,corners(1,1)) min(corners(2,1),size(projection,2))];
         
    delete(cropFig);
else
    load(rangeFile);
end
projection = projection(range(1,1):range(1,2),range(2,1):range(2,2));

%load full tiff and crop
tiff = loadtiffAM(tiffPath);
tiff = tiff(range(1,1):range(1,2),range(2,1):range(2,2),:);

%save files
saveasbigtiff(tiff,[fullfile(path,name),'_crop',ext]);
saveasbigtiff(projection,[fullfile(path,name),'_zProj_crop',ext]);
save([fullfile(path,name),'_cropDimensions','.mat'],'range');

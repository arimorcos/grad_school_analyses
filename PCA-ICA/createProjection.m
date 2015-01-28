function createProjection(tiffPath)
%loads in tiff and creates an avg projection

%load in tiff
tiff = loadtiffAM(tiffPath);

%create projection
projection = mean(tiff,3);

%create output string
[path,name,ext] = fileparts(tiffPath);
newName = [fullfile(path,name),'_zProj',ext];

%save
saveasbigtiff(projection,newName);
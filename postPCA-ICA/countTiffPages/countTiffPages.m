function numImages = countTiffPages(filename)

hTif = Tiff(filename,'r');

numImages = 1;
while ~hTif.lastDirectory()
    numImages = numImages + 1;
    hTif.nextDirectory();
end
hTif.setDirectory(1);

close(hTif);

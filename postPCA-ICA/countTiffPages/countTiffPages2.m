function numImages = countTiffPages2(filename)

hTif = Tiff(filename,'r');

header = hTif.getTag('ImageDescription');
match = regexp(header,'acqNumFrames = \d*','match');

if ~isempty(match)
    numImages = sscanf(match{1}, 'acqNumFrames = %d');
else
    error('Error reading the number of images');
end

close(hTif);

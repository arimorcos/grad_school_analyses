function nPages = getNPagesMultiFile(folderPath,fileStr)
%getNPagesMultiFile.m Calculates number of pages for multiple files
%
%INPUTS
%folderPath - path to folder
%fileStr - regExp match string for files
%
%OUTPUTS
%nPages - scalar of number of frames
%
%ASM 5/14

%get fileList
fileList = getMatchingFileList(folderPath,fileStr);
nFiles = length(fileList);

if nFiles == 0
    error('No files found matching file string');
end

%get nPages of first file
nPagesFirst = getNPages(fileList{1},500);

%get nPages of last file 
nPagesLast = getNPages(fileList{end},500);

%get nPages of mid file 
nPagesMid = getNPages(fileList{round(nFiles/2)},500);

%calculate nPages
if nPagesFirst == nPagesMid 
    nPages = (nFiles-1)*nPagesFirst + nPagesLast;
else
    nPages = nPagesFirst;
    for i = 2:nFiles
        nPages = nPages + getNPages(fileList{i},500);
    end
end
    
    

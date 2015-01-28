function [catFileName, catFileFullName, catFilePath, outTiff] = cat_tif(save,...
    silent,tifFileNames,catFileFullName)
%cat_tif.m Concatenates tif files to form one long tif movie. 
%
%ASM 9/2/13 based off concatenate_tif_files.m
if nargin < 2; silent = false; end;
if nargin < 1; save = true; end;

%set baseDir
BASEDIR = 'K:\DATA\2P Data';

%change to dir
origDir = cd(BASEDIR);

if ~silent
    %initialize cells
    tifFileNames = {};

    getFiles = true;

    while getFiles

        %get tif files in folder
        [tempTifFileNames,tempTifPath] = ...
            uigetfile('*.tif','Select Tiff Files','MultiSelect','on');

        %check if canceled
        if isequal(tempTifFileNames,0) && isempty(tifFileNames) %if canceled
            disp('No .tif files selected');
            return;
        elseif isequal(tempTifFileNames,0) && ~isempty(tifFileNames) 
            cancelFlag = true;
        else
            cancelFlag = false;
        end

        if ~cancelFlag
            %if only one file selected
            if ischar(tempTifFileNames)
                tempTifFileNames = {tempTifFileNames};
            end

            %create cell array of file names
            numFiles = length(tempTifFileNames);
            for j = 1:numFiles
                tifFileNames{length(tifFileNames)+1} = ...
                    fullfile(tempTifPath,tempTifFileNames{j}); %#ok<AGROW>
            end
        end

        %check if more folders
        moreFiles = questdlg('Are there more files?');
        switch moreFiles
            case 'Yes'
                getFiles = true;
            case {'No','Cancel'}
                getFiles = false;
        end
    end

    %get output file name
    cd(tempTifPath);
    [catFileName,catFilePath] = uiputfile('*.tif','Enter concatenated file name');
    catFileFullName = fullfile(catFilePath,catFileName);
else
    [catFilePath,catFileName] = fileparts(catFileFullName);
    catFileName = [catFileName,'.tif'];
end

%open files and concatenate; scale for same intensities
cated_movie=[];
h = waitbar(0,['Loading .tif...0/',num2str(length(tifFileNames))]);
for i=1:length(tifFileNames)
    waitbar(i/length(tifFileNames),h,['Loading .tif...',num2str(i),'/',num2str(length(tifFileNames))]);
    tifFile = tifFileNames{i};
    chone = loadtiffAM(tifFile);
    
    %scale movie for seamless intensities
    if i==1
        meanlastframes=median(mean(mean(chone(:,:,1:300))));
    end

    meanfirstframes=median(mean(mean(chone(:,:,1:300))));
    chone=chone*(meanlastframes/meanfirstframes);
    cated_movie=cat(3,cated_movie,chone);
    meanlastframes=median(mean(mean(chone(:,:,end-300:end))));
end


%outTiff
waitbar(1,h,'Converting .tif...')
outTiff = uint16(cated_movie);

%save movie
if save
    waitbar(1,h,'Saving .tif...');
%     iowritemovie_tif(outTiff,catFileFullName);
    saveasbigtiff(outTiff,catFileFullName);
end
delete(h);
%change back to original directory
cd(origDir);
end
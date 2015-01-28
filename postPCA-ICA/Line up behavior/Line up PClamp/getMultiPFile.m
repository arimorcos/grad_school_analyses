function planeItRanges = getMultiPFile(folderPath,fileStr,nPlanes,nExtraPlanes,...
    nChannels,pPath,mouseName,date,tiffBase)
%getMultiPFile Asks user for multiple pFiles to fill out a concatenated
%file
%
%INPUTS
%folderPath - path containing multi-part tiff
%fileStr - regexp string for multi-part tiff
%nPlanes - number of planes imaged from
%nExtraPlanes - number of flyback planes
%nChannels - number of channels
%pPath - path to pFile directory
%mouseName - mouseName being used
%date - date being used
%tiffBase - tiff name
%
%OUTPUTS
%planeItRanges - 1 x nPlanes cell containing iteration ranges for each
%   frame of each plane
%
%ASM 11/13
%UPDATED ASM 5/14 for multi-part tiffs

%figure out nFrames total
nFrames = getNPagesMultiFile(folderPath,fileStr)/nChannels;

%create waitbar
pWait = waitbar(0/nFrames,sprintf('%d/%d frames accounted for %s',0,nFrames,...
    tiffBase));
set(findall(pWait,'type','text'),'Interpreter','none');
setWaitbarLoc(pWait);

%ask for pFiles until complete
gotAllPFiles = false;
planeItRanges = cell(1,nPlanes);
multiFiles = false;
firstGo = true;
while ~gotAllPFiles
    
    if ~multiFiles || fileInd >= nFiles
        if ~firstGo
            %get pFile
            origDir = cd(fullfile(pPath,mouseName,date)); %change to pClamp dir
            [pName,pDir] = uigetfile('*.abf','Select pClamp file','MultiSelect','On');
            if ~iscell(pName) && pName == 0 %if canceled
                return;
            end
        else
            origDir = cd(fullfile(pPath,mouseName,date)); %change to pClamp dir
            pDir = fullfile(pPath,mouseName,date);
            pName = dir2cell(pDir);
            pName = pName(3:end);
            firstGo = false;
        end
        if iscell(pName)
            nFiles = length(pName);
            allPFiles = cell(1,nFiles);
            for i = 1:nFiles
                allPFiles{i} = fullfile(pDir,pName{i});
            end
            multiFiles = true;
            pFile = allPFiles{1};
            fileInd = 1;
        else
            pFile = fullfile(pDir,pName);
        end
        cd(origDir);
    else
        fileInd = fileInd + 1;
        pFile = allPFiles{fileInd};
    end
    
    %align and split pClamp file
    [~, tempPlaneItRanges] = alignSplitPClamp(pFile,nPlanes,nExtraPlanes);
    
    for planeInd = 1:nPlanes
        %concatenate
        planeItRanges{planeInd} = cat(1,planeItRanges{planeInd},tempPlaneItRanges{planeInd});
    end
    %update waitbar
    waitbar(size(planeItRanges{1},1)/nFrames,pWait,sprintf(...
        '%d/%d frames accounted for %s',size(planeItRanges{1},1),nFrames,tiffBase));
    
    %check if done
    if size(planeItRanges{1},1) == nFrames
        gotAllPFiles = true;
        delete(pWait);
        if fileInd < nFiles
            warning('Did not use all files for virmen alignment');
        end
    elseif size(planeItRanges{1},1) > nFrames && nPlanes == 1
        gotAllPFiles = true;
        delete(pWait);
        warning('Found extra frame clock signals...assuming dropped frames at end');
        planeItRanges{1} = planeItRanges{1}(1:nFrames,:);
    end
    
end
end
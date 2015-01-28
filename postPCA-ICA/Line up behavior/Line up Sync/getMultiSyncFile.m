function planeItRanges = getMultiSyncFile(nFrames,nPlanes,nExtraPlanes,...
    syncPath,mouseName,acqDate,tiffBase)
%getMultiPFile Asks user for multiple pFiles to fill out a concatenated
%file
%
%INPUTS
%nFrames - total frames
%nPlanes - number of planes imaged from
%nExtraPlanes - number of flyback planes
%nChannels - number of channels
%syncPath - path to pFile directory
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

if nargin < 7 || isempty(tiffBase)
    tiffBase = '';
end

%create waitbar
syncWait = waitbar(0/nFrames,sprintf('%d/%d frames accounted for %s',0,nFrames,...
    tiffBase));
set(findall(syncWait,'type','text'),'Interpreter','none');
setWaitbarLoc(syncWait);

%ask for pFiles until complete
gotAllPFiles = false;
planeItRanges = cell(1,nPlanes);
multiFiles = false;
firstGo = true;
while ~gotAllPFiles
    
    if ~multiFiles || fileInd >= nFiles
        if ~firstGo
            %get pFile
            origDir = cd(fullfile(syncPath,mouseName,acqDate)); %change to pClamp dir
            [syncName,syncDir] = uigetfile('*.abf','Select pClamp file','MultiSelect','On');
            if ~iscell(syncName) && syncName == 0 %if canceled
                return;
            end
        else
            origDir = cd(fullfile(syncPath,mouseName,acqDate)); %change to pClamp dir
            syncDir = fullfile(syncPath,mouseName,acqDate);
            syncName = dir2cell(syncDir);
            syncName = syncName(3:end);
            firstGo = false;
        end
        if iscell(syncName)
            nFiles = length(syncName);
            allPFiles = cell(1,nFiles);
            for i = 1:nFiles
                allPFiles{i} = fullfile(syncDir,syncName{i});
            end
            multiFiles = true;
            pFile = allPFiles{1};
            fileInd = 1;
        else
            pFile = fullfile(syncDir,syncName);
        end
        cd(origDir);
    else
        fileInd = fileInd + 1;
        pFile = allPFiles{fileInd};
    end
    
    %align and split pClamp file
    [~, tempPlaneItRanges] = alignSplitSync(pFile,nPlanes,nExtraPlanes);
    
    for planeInd = 1:nPlanes
        %concatenate
        planeItRanges{planeInd} = cat(1,planeItRanges{planeInd},tempPlaneItRanges{planeInd});
    end
    %update waitbar
    waitbar(size(planeItRanges{1},1)/nFrames,syncWait,sprintf(...
        '%d/%d frames accounted for %s',size(planeItRanges{1},1),nFrames,tiffBase));
    
    %check if done
    if size(planeItRanges{1},1) == nFrames
        gotAllPFiles = true;
        delete(syncWait);
        if fileInd < nFiles
            warning('Did not use all files for virmen alignment');
        end
    elseif size(planeItRanges{1},1) > nFrames && nPlanes == 1
        gotAllPFiles = true;
        delete(syncWait);
        warning('Found extra frame clock signals...assuming dropped frames at end');
        planeItRanges{1} = planeItRanges{1}(1:nFrames,:);
    end
    
end
end
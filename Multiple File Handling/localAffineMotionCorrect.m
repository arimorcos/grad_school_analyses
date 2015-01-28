function localAffineMotionCorrect(folderPath,fileStr,silent,nCores)
%localAffineMotionCorrect.m Performs motion correction for a set of files
%in a given folder matching fileStr. Automatically performs motion
%correction on red files and then applies same shifts to green files as
%well
%
%INPUTS
%folderPath - path to folder
%fileStr - regexp fileStr to match files to motion correct
%silent - should run silently or not
%nCores - nCores to use
%
%ASM 5/14

%%%%%%%%%%% CONSTANTS %%%%%%%%%%%%%%
nSegments = 9;
nFramesNorm = 300;
downsampleFac = 2;

%%%%%%%%%%%%%%%%%%%% FIND FILE LIST %%%%%%%%%%%%%%%%%%%%%
if nargin < 4 || isempty(nCores)
    nCores = nSegments;
else
    nCores = min(nCores,nSegments);
end
if nargin < 3 || isempty(silent)
    silent = false;
end

fileList = getMatchingFileList(folderPath,fileStr);

%get nFiles
nFiles = length(fileList);

%get number of acquisitions
acqNames = unique(cellfun(@(x) x{1},regexp(fileList,'(?<=_)\d\d\d(?=_\d\d\d.tif)','match'),'UniformOutput',false));
nAcquisitions = length(acqNames);

%get number of files for each acquisition
nAcqFiles = zeros(1,nAcquisitions);
acqIds = zeros(1,nFiles);
currInd = 0;
for acqInd = 1:nAcquisitions
    nAcqFiles(acqInd) = sum(~cellfun(@isempty,regexp(fileList,['(?<=_',acqNames{acqInd},'_)\d\d\d(?=.tif)'])));
    acqIds(currInd+1:currInd+nAcqFiles(acqInd)) = str2double(acqNames(acqInd));
    currInd = currInd + nAcqFiles(acqInd);
end
lastAcqFiles = cumsum(nAcqFiles(1:end));
firstAcqFiles = [1 lastAcqFiles(1:end-1) + 1];

%get size of all files
totalSize = 0;
for fileInd = 1:nFiles
    totalSize = totalSize + convertBytes(getFileSize(fileList{fileInd}),'GB');
end

%get total free space 
totalFreeSpace = convertBytes(disk_free(folderPath),'GB');

%if total free space is smaller than total file size, throw error
if totalSize > totalFreeSpace 
    error('localAffineMotionCorrect:DiskSpaceError',['Not enough disk space available in drive %s ',...
        'to complete motion correct. Please delete some files.'],folderPath);
end

%get general info
[~,sImage,sImageStr] = loadtiffAM(fileList{1},1);

%get baseStr
baseStr = sImage.loggingFileStem;

%get channelNames
channelNames = sImage.channelsMergeColor(sImage.channelsSave);
nChannels = length(channelNames);

%get nPlanes
if sImage.fastZEnable
    nExtraPlanes = sImage.fastZNumDiscardFrames;
    nPlanes = sImage.stackNumSlices;
else
    nPlanes = 1;
    nExtraPlanes = 0;
end

%get framesPerFile
totFramesPer = sImage.loggingFramesPerFile*nChannels;
framesPer = sImage.loggingFramesPerFile/(nPlanes+nExtraPlanes);

%%%%%%%%%%%%% CREATE MASK %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~silent
    %load tiff
    maskTiff = mean(loadtiffAM(fileList{1},1:nChannels*(nPlanes+nExtraPlanes):400),3);
    
    %graphically create mask
    maskFig = figure;
    imshow(histeq(maskTiff/max(maskTiff(:)))),
    h=imrect;
    pause;
    mask = round(getPosition(h));
    if isodd(mask(3));mask(3) = mask(3)-1;end
    if isodd(mask(4));mask(4) = mask(4)-1;end
    delete(maskFig);
else
    %load tiff
    maskTiff = mean(loadtiffAM(fileList{1},1:nChannels*(nPlanes+nExtraPlanes):400),3);
    mask = [round(0.08*size(maskTiff,1)) 2  size(maskTiff,1) - round(0.08*size(maskTiff,1)) ...
        size(maskTiff,2)-4];
    if isodd(mask(3));mask(3) = mask(3)-1;end
    if isodd(mask(4));mask(4) = mask(4)-1;end
end


%%%%%%%%%%%%%%%% CALCULATE SHIFTS %%%%%%%%%%%%%%%%%%%%%%%%%%
%create waitbar
hWait = waitbar(0,'Creating Parallel Pool');
setWaitbarLoc(hWait,800);

%create parallel pool
if isempty(gcp('nocreate'))
    poolObj = parpool(nCores);
else
    poolObj = gcp;
end

%update waitbar
waitbar(0,hWait,'Initializing');

%initialize arrays for mean intensity
meanLast = zeros(1,nAcquisitions);
meanFirst = zeros(1,nAcquisitions);

%initialize shifts
xShifts = cell(nPlanes,nFiles);
yShifts = cell(size(xShifts));
xShiftsAcq = zeros(nPlanes,nFiles);
yShiftsAcq = zeros(size(xShiftsAcq));

%initialize refFrame
fileRefFrames = cell(1,nPlanes);
for i = 1:nPlanes
    fileRefFrames{i} = zeros(mask(4)+1,mask(3)+1,nFiles);
end

%get custom file indices starting in the middle
fileOrder = [round(nFiles/2):nFiles (round(nFiles/2)-1):-1:1];
refAcq = acqIds(fileOrder(1));

%process channels so red is first
redInd = find(strcmp(channelNames,'red'));
channelOrder = [redInd setdiff(1:nChannels,redInd)];

%initalize totalInd
totalInd = 1;
totalShifts = nFiles*nPlanes;

%initialize projection
projTiff = cell(nPlanes,nChannels);
for i = 1:length(projTiff)
    projTiff{i} = zeros(mask(4)+1,mask(3)+1);
end

%loop through each file and get shifts
for fileInd = fileOrder %for each file starting in the center
    
    %update waitbar
    waitbar(find(fileInd == fileOrder)/nFiles,hWait,sprintf('Loading file %d/%d',...
        find(fileInd == fileOrder),nFiles));
    
    %load movie, ignoring extra planes
    if nExtraPlanes > 0
        indToLoad = setdiff(1:totFramesPer,bsxfun(@plus,(-1:0)',...
            (nChannels*(nPlanes+nExtraPlanes):nChannels*(nPlanes+nExtraPlanes):totFramesPer))); %generate indices
    else
        indToLoad = 1:totFramesPer;
    end
    [currTiffWhole,currSImage] = loadtiffAM(fileList{fileInd},indToLoad);
    
    %convert to double
    currTiffWhole = double(currTiffWhole);
    
    %crop image
    currTiffWhole = currTiffWhole(mask(2):mask(2)+mask(4),mask(1):mask(1)+mask(3),:);
    
    %correct line shift
    waitbar(find(fileInd == fileOrder)/nFiles,hWait,sprintf('Correcting line shift %d/%d',...
        find(fileInd == fileOrder),nFiles));
    currTiffWhole = correctLineShift(currTiffWhole);
    
    %update waitbar
    %     multiWaitbar('Loading tiff files',find(fileInd==fileOrder)/nFiles);
    
    %split into each plane
    for planeInd = 1:nPlanes %for each plane
        
        %get plane indices
        framesForPlane = bsxfun(@plus,(0:nChannels-1)',planeInd:nPlanes*nChannels:size(currTiffWhole,3));
        
        %split out plane
        currPlaneTiff = currTiffWhole(:,:,framesForPlane(:));
        
        %split out channels
        for channelInd = channelOrder %for each channel
            
            %get channel indices
            framesForChannel = channelInd:nChannels:size(currPlaneTiff,3);
            
            %split out channel
            currChannelTiff = currPlaneTiff(:,:,framesForChannel);
            
            %calculate shifts if channel is red
            if channelInd == redInd %if red
                
                %update waitbar
                waitbar(totalInd/totalShifts,hWait,sprintf('Calculating shift... file %d/%d, plane %d/%d, shift %d/%d',...
                    find(fileInd==fileOrder),nFiles,planeInd,nPlanes,totalInd,totalShifts));
                
                
                %calculate within acquisition shifts
                [xShifts{planeInd,fileInd},yShifts{planeInd,fileInd},segPos,...
                    fileRefFrames{planeInd}(:,:,fileInd)] =...
                    trackSegmentsAM(currChannelTiff,nSegments,downsampleFac);
                %                 [xShifts{planeInd,fileInd},yShifts{planeInd,fileInd},segPos,...
                %                     fileRefFrames{planeInd}(:,:,fileInd)] =...
%                     trackFeatures(currChannelTiff);
                
                
                %increment index
                totalInd = totalInd + 1;
                
                %calculate between acquisition shift
                if fileInd ~= fileOrder(1) %if not first acquisition
                    
                    %shift fileRefFrames{planeInd}(:,:,fileInd) relative to
                    %fileRefFrames{planeInd}(:,:,fileOrder(1)) (total
                    %refFrame)
                    [xShiftsAcq(planeInd,fileInd),yShiftsAcq(planeInd,fileInd)] = ...
                        track_subpixel_motion_fft(fileRefFrames{planeInd}(:,:,fileInd),...
                        fileRefFrames{planeInd}(:,:,fileOrder(1)));
                    
                    %modify shifts
                    xShiftToPerform = -(xShifts{planeInd,fileInd} + xShiftsAcq(planeInd,fileInd));
                    yShiftToPerform = -(yShifts{planeInd,fileInd} + yShiftsAcq(planeInd,fileInd));
                else
                    xShiftToPerform = -xShifts{planeInd,fileInd};
                    yShiftToPerform = -yShifts{planeInd,fileInd};
                    
                end
                
                
            end
            
            %perform shifts
            waitbar(totalInd/totalShifts,hWait,sprintf('Performing shift... file %d/%d, plane %d/%d, channel %d/%d',...
                find(fileInd==fileOrder),nFiles,planeInd,nPlanes,find(channelInd==channelOrder),nChannels));
            currChannelTiff = uint16(currChannelTiff);
            currChannelTiffShifted = affineAdjustTIFF(currChannelTiff,xShiftToPerform,yShiftToPerform,segPos);
            
            %normalize intensity
            if ismember(fileInd,lastAcqFiles) %if a last acquisition
                meanLast(fileInd==lastAcqFiles) =...
                    mean(mean(mean(currChannelTiffShifted(:,:,end-nFramesNorm+1:end))));
            end
            if ismember(fileInd,firstAcqFiles)
                meanFirst(fileInd==firstAcqFiles) =...
                    mean(mean(mean(currChannelTiffShifted(:,:,1:nFramesNorm))));
            end
            currAcq = acqIds(fileInd);
            if currAcq > refAcq %current acquisition comes after the reference acquisition
                scaleFac = meanFirst(currAcq)/meanLast(currAcq-1);
                currChannelTiffShifted = currChannelTiffShifted./scaleFac;
            elseif currAcq < refAcq %current acquisition comes before reference acquisition
                scaleFac = meanLast(currAcq)/meanFirst(currAcq+1);
                currChannelTiffShifted = currChannelTiffShifted./scaleFac;
            end
            
            %save (convert back to uint16)
            waitbar(totalInd/totalShifts,hWait,sprintf('Saving... file %d/%d, plane %d/%d, channel %d/%d',...
                find(fileInd==fileOrder),nFiles,planeInd,nPlanes,find(channelInd==channelOrder),nChannels));
            %generate save string
            saveStr = sprintf('%s%s%s_%03d_Plane%03d_%s.tif',folderPath,filesep,baseStr,fileInd,planeInd,channelNames{channelInd});
            saveastiffAM(currChannelTiffShifted,saveStr,[],{'ImageDescription',sImageStr});
            
            %store in projection
            projTiff{planeInd,channelInd} = projTiff{planeInd,channelInd} + sum(double(currChannelTiffShifted),3)./size(currChannelTiffShifted,3);
            
        end
    end
    
end

%average projections and save
for planeInd = 1:nPlanes
    for channelInd = 1:nChannels
        saveStr = sprintf('%s%s%s_Plane%03d_%s_avgProj.tif',folderPath,filesep,baseStr,planeInd,channelNames{channelInd});
        avgProjToSave = projTiff{planeInd,channelInd};
        maxProjToSave = avgProjToSave./nFiles;
        saveastiffAM(uint16(avgProjToSave),saveStr,[],{'ImageDescription',sImageStr});
        saveStr = sprintf('%s%s%s_Plane%03d_%s_avgProj.tif',folderPath,filesep,baseStr,planeInd,channelNames{channelInd});
        saveastiffAM(uint16(maxProjToSave),saveStr,[],{'ImageDescription',sImageStr});
        
    end
end

%close parallel pool
delete(poolObj);

%close waitbar
delete(hWait);


function [tiffChannels] = splitChannels(tiff,shouldSave,...
    shouldDelete,silent,overwrite)
%splitChannels.m Function to split apart tiff channels
%
%INPUTS
%tiff - either height x width x nPages tiff array OR a full file path to a
%   tiff file to be loaded
%shouldSave - boolean of whether or not to save new file. Only works if
%   tiff input is a filepath.
%shouldDelete - boolean of whether or not to delete original, unsplit file.
%   Only works if tiff input is a filepath.
%silent - boolean of whether or not to be silent
%overwrite - boolean of whether or not to overwrite files
%
%OUTPUTS
%tiffChannels - 1 x nChannels cell array containing channels split up
%
%ASM 4/14

%%%%%%%%%%%%%%%%%%%%%%%%%%% PARSE ARGUMENTS %%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 5 || isempty(overwrite)
    overwrite = true;
end
if nargin < 4 || isempty(silent) || silent ~= 0
    silent = false;
    if ishandle(silent)
        hWait = silent;
    else
        hWait = waitbar(0,'Splitting tiff...');
    end
end
if nargin < 3 || isempty(shouldDelete)
    shouldDelete = false;
end
if nargin < 3 || isempty(shouldSave)
    shouldSave = false;
end
if ischar(tiff) %if a path
    tiffPath = tiff;
    if ~silent || ishandle(silent)
        waitbar(0,hWait,untexlabel(sprintf('Loading %s...',tiffPath)));
    end
    [tiff,sImage] = loadtiffAM(tiffPath);
    channelNames = sImage.channelsMergeColor(sImage.channelsSave);
else
    shouldDelete = false;
    shouldSave = false;
    channelNames = {'green','red'};
end

%%%%%%%%%%%%%%%%%%%%%% SPLIT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%get nChannels
nChannels = length(channelNames);

%get nFrames
nFrames = size(tiff,3);

%initialize tiffChannels
tiffChannels = cell(1,nChannels);

%update waitbar
if ~silent || ishandle(silent)
    waitbar(0,hWait,'Splitting tiff...');
end

%split tiff
for i = 1:nChannels
    
    %generate frame indices
    framesToGet = i:nChannels:nFrames;
    
    %split
    tiffChannels{i} = tiff(:,:,framesToGet);
    
end

%save if necessary
if shouldSave 
    
    for i = 1:nChannels
        
        %update waitbar
        if ~silent || ishandle(silent)
            waitbar(i/nChannels,hWait,sprintf('Saving %s channel %d/%d',channelNames{i},i,nChannels));
        end
        
        %generate new file name
        [path,file,ext] = fileparts(tiffPath);
        newName = sprintf('%s%s%s_%s%s',path,filesep,file,channelNames{i},ext);
        
        %check if file exists and overwrite if commanded to
        if exist(newName,'file')
            if overwrite
                delete(newName);
            else
                continue;
            end
        end            
        
        %save
        saveastiff(tiffChannels{i},newName);
        
    end
end

%delete original file
if shouldDelete 
    delete(tiffPath);
end

%delete waitbar
if ~silent && ~ishandle(silent)
    delete(hWait);
end
        
        
            
            
            
            
            
            
            
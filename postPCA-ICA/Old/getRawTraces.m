function traces = getRawTraces(tiff,filters,hWait)
%getRawTraces.m Function to extract raw traces given a set of filters 
%
%INPUTS
%tiff - path to tiff file or m x n x nFrames tiff array
%filters - m x n x nFilters binary array of filters 
%hWait - handle for waitbar 
%
%OUTPUTS
%traces - nFilters x nFrames array of traces
%
%ASM 3/14
%UPDATED ASM 5/14 to accomodate file path

if ischar(tiff)
    tiff = loadtiffAM(tiff);
end

%reshape tiff into nPixels x nFrames
tiff = single(reshape(tiff,size(tiff,1)*size(tiff,2),size(tiff,3)));

%reshape filters into nPixels x nFilters
filters = logical(reshape(filters,size(filters,1)*size(filters,2),size(filters,3)));

%get nFilters
nFilters = size(filters,2);

%get nFrames
nFrames = size(tiff,2);

%initialize traces
traces = zeros(nFilters,nFrames);

%create waitbar
if nargin < 3 || isempty(hWait)
    hWait = waitbar(0,'Getting raw traces');
else
    if ishandle(hWait)
        waitbar(0,hWait,'Getting raw traces');
    end
end

%loop through each filter and calculate
for i = 1:nFilters %for each frame
    
    %find current filter's pixels
    currPix = filters(:,i);
    
    %multiply filter by tiff
    pixVals = tiff(currPix,:);
    
    %take mean of pixVals
    traces(i,:) = mean(pixVals);
    
    clear pixVals;
    
    if ishandle(hWait)
        waitbar(i/nFilters,hWait,sprintf('Getting raw trace %d/%d',i,nFilters));
    end
end

if nargin < 3
    delete(hWait);
end
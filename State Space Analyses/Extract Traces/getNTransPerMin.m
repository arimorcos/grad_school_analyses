function nTransPerMin = getNTransPerMin(dFFTraces,frameRate)
%nTransPerMin = getNTransPerMin(dFFTraces) calculates the number of
%transients per minute
%
%INPUTS
%dFFTraces - cell array of each plane - nCells x nFrames array that has been thresholded
%frameRate - frame rate in frames/sec
%
%OUTPUTS
%nTransPerMin - nCells x 1 array of number of transients per minute
%
%ASM 2/14

if ~iscell(dFFTraces)
    dFFTraces = {dFFTraces};
end

nTransPerMin = cell(1,length(dFFTraces));
for i = 1:length(dFFTraces);
    %get total frames
    nFrames = size(dFFTraces{i},2);

    %get total time in minutes
    nMin = nFrames*(1/frameRate)*(1/60);
    
    %get nCells
    nCells = size(dFFTraces{i},1);
    
    %get total number of transients for each cell
    nTransients = zeros(nCells,1);
    for j = 1:nCells %for each transient
        nTransients(j) = length(findContinuousRegions(dFFTraces{i}(j,:)));
    end

    %get nTransients per min
    nTransPerMin{i} = nTransients./nMin;
end
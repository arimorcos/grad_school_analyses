function [nAcq, sepData] = separatePClampAcq(data)
%separatePClampAcq.m Checks if multiple acquisitions in same file. If so,
%splits into separate data arrays
%
%INPUTS
%data - pClamp data file 2 x nSamples
%
%OUTPUTS
%nAcq - number of acquisitions
%sepData - 1 x nAcq cell containing 2 x nSamples array for each acquisition
%
%ASM 10/13

%extract frame data
fData = data(2,:);

%smooth data
smoothFData = smooth(fData,100);

%find periods where > 0 
acquiring = smoothFData > 0.5;

%find nAcq
nAcq = length(unique(bwlabel(acquiring))) - 1;

%initialize sepData
sepData = cell(1,nAcq);

%separate if nAcq is greater than 1 
if nAcq > 1 
    dAcq = diff(acquiring);
    endInd = find(dAcq == -1)+1;
    startInd = find(dAcq == 1)+1;
    
    for i = 1:nAcq %for each split
        sepData{i} = data(:,startInd(i) - 1e4:endInd(i) + 1e4);
    end
end
        
        
        
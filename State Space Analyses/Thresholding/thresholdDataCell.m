function dataCell = thresholdDataCell(dataCell,nSTD,minFrames)
%zScoreDataCell.m Takes in dataCell and thresholds
%
%INPUTS
%dataCell - dataCell containing imaging data
%nSTD - nSTD to cut off
%minFrames - minFrames above std threshold
%
%ASM 9/14

if nargin < 3 || isempty(minFrames)
    minFrames = 8;
end
if nargin < 2 || isempty(nSTD)
    nSTD = 2.5;
end

%get traces
dFFTraces = dataCell{1}.imaging.completeDFFTrace;
% dGRTraces = dataCell{1}.imaging.completeDGRTrace;

%threshold
dFFThresh = thresholdCompleteTrace(dFFTraces,nSTD,minFrames);
% dGRThresh = thresholdCompleteTrace(dGRTraces,nSTD,minFrames);

%copy back
dataCell = standaloneCopyDFFToDataCell(dataCell,dFFThresh);
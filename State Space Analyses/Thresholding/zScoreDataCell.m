function dataCell = zScoreDataCell(dataCell)
%zScoreDataCell.m Takes in dataCell and zScores
%
%
%
%ASM 9/14

%get traces
dFFTraces = dataCell{1}.imaging.completeDFFTrace;
% dGRTraces = dataCell{1}.imaging.completeDGRTrace;

%zscore
dFFTraces = zScoreTraces(dFFTraces);
% dGRTraces = zScoreTraces(dGRTraces);

%copy back
dataCell = standaloneCopyDFFToDataCell(dataCell,dFFTraces,dGRTraces);
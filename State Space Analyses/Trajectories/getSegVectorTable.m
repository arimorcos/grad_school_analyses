function segVectorTable = getSegVectorTable(dataCell)
%getSegVectorTable.m Wrapper to extract table 
%
%ASM 2/15

%get mean subtracted trajectories
meanSubTraj = getMeanSubtractedTrajectoriesSepPrevTurn(dataCell);

%get maze patterns
mazePatterns = getMazePatterns(dataCell);

%get segVectorTable 
segVectorTable = getSegVectors(meanSubTraj,mazePatterns);
function dataCell = addPrevTrialResult(dataCell)
%addPrevTrialResult.m Adds the previous trial result to the dataCell
%
%ASM 1/15

%get trial results
trialTurns = getCellVals(dataCell,'result.leftTurn');
prevTrialTurns = cat(2,NaN,trialTurns(1:end-1));

%get trialNumLeft
trialNumLeft = getCellVals(dataCell,'maze.numLeft');
prevTrialNumLeft=  cat(2,NaN,trialNumLeft(1:end-1));

%get trialCorrect
trialCorrect = getCellVals(dataCell,'result.correct');
prevTrialCorrect = cat(2,NaN,trialCorrect(1:end-1));

%get crutchTrial 
crutchTrial = getCellVals(dataCell,'maze.crutchTrial');
prevCrutchTrial = cat(2,NaN,crutchTrial(1:end-1));

%assign to each field in dataCell
for i = 1:length(dataCell)
    dataCell{i}.result.prevTurn = prevTrialTurns(i);
    dataCell{i}.result.prevNumLeft = prevTrialNumLeft(i);
    dataCell{i}.result.prevCorrect = prevTrialCorrect(i);
    dataCell{i}.result.prevCrutch = prevCrutchTrial(i);
end
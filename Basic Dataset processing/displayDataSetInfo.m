function displayDataSetInfo(dataCell)

%get number of cells 
nCells = sum(dataCell{find(findTrials(dataCell,'imaging.imData==1'),1,'first')}.imaging.roiGroups{1} == 1);

%get 6-0 performance and nTrials 
trials60 = getTrials(dataCell,'maze.numLeft==0,6');
nTrials60 = length(trials60);
perf60 = 100*sum(getCellVals(trials60,'result.correct'))/nTrials60;

%get 5-1 performance and nTrials 
trials51 = getTrials(dataCell,'maze.numLeft==1,5');
nTrials51 = length(trials51);
perf51 = 100*sum(getCellVals(trials51,'result.correct'))/nTrials51;

%get 4-2 performance and nTrials 
trials42 = getTrials(dataCell,'maze.numLeft==2,4');
nTrials42 = length(trials42);
perf42 = 100*sum(getCellVals(trials42,'result.correct'))/nTrials42;

%get 3-3 performance and nTrials 
trials33 = getTrials(dataCell,'maze.numLeft==3');
nTrials33 = length(trials33);
perf33 = 100*sum(getCellVals(trials33,'result.correct'))/nTrials33;

%print 
fprintf('nCells: %d\n',nCells);
fprintf('6-0 performance: %.1f%%, 6-0 trials: %d\n',perf60,nTrials60);
fprintf('5-1 performance: %.1f%%, 5-1 trials: %d\n',perf51,nTrials51);
fprintf('4-2 performance: %.1f%%, 4-2 trials: %d\n',perf42,nTrials42);
fprintf('3-3 performance: %.1f%%, 3-3 trials: %d\n',perf33,nTrials33);

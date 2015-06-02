function createInputDataSVM(imTrials,saveFolder)
%creates and saves input data

%get mouse name and date
mouse = imTrials{1}.info.mouse;
date = imTrials{1}.info.date;

%60 left right 
trials60 = getTrials(imTrials,'maze.numLeft==0,6');
realClass = getCellVals(trials60,'result.leftTurn');
[~,traces] = catBinnedTraces(trials60);
yPosBins = imTrials{1}.imaging.yPosBins;
saveName60 = sprintf('%s%s%d_%s_leftRight_60_data.mat',saveFolder,filesep,mouse,date);
save(saveName60,'realClass','traces','yPosBins');
clear traces;
clear realClass;

%all left right 
realClass = getCellVals(imTrials,'result.leftTurn');
[~,traces] = catBinnedTraces(imTrials);
saveNameAllLeftRight = sprintf('%s%s%d_%s_leftRight_allTrials_data.mat',saveFolder,filesep,mouse,date);
save(saveNameAllLeftRight,'realClass','traces','yPosBins');
clear traces;
clear realClass;

%all prevTurn
realClass = getCellVals(imTrials,'result.prevTurn');
[~,traces] = catBinnedTraces(imTrials);
saveNameAllPrevTurn = sprintf('%s%s%d_%s_prevTurn_allTrials_data.mat',saveFolder,filesep,mouse,date);
save(saveNameAllPrevTurn,'realClass','traces','yPosBins');
clear traces;
clear realClass;

%all prevCorrect
realClass = getCellVals(imTrials,'result.prevCorrect');
[~,traces] = catBinnedTraces(imTrials);
saveNameAllPrevCorrect = sprintf('%s%s%d_%s_prevCorrect_allTrials_data.mat',saveFolder,filesep,mouse,date);
save(saveNameAllPrevCorrect,'realClass','traces','yPosBins');
clear traces;
clear realClass;

%all correct
realClass = getCellVals(imTrials,'result.correct');
[~,traces] = catBinnedTraces(imTrials);
saveNameAllCorrect = sprintf('%s%s%d_%s_correct_allTrials_data.mat',saveFolder,filesep,mouse,date);
save(saveNameAllCorrect,'realClass','traces','yPosBins');
clear traces;
clear realClass;

%all firstSeg
mazePatterns = getMazePatterns(imTrials);
realClass = mazePatterns(:,1);
[~,traces] = catBinnedTraces(imTrials);
firstSegInd = yPosBins >= 0 & yPosBins < 80;
traces = traces(:,firstSegInd,:);
yPosBins = yPosBins(firstSegInd);
saveNameAllFirstSeg = sprintf('%s%s%d_%s_firstSeg_allTrials_data.mat',saveFolder,filesep,mouse,date);
save(saveNameAllFirstSeg,'realClass','traces','yPosBins');
clear traces;
clear realClass;


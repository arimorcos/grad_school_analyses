
imTrials = getTrials(dataCell,'maze.crutchTrial==0;result.correct==1;imaging.imData==1');

segToNorm = 1;
netEv = getNetEvidence(imTrials);
netEvSeg = netEv(:,segToNorm);

uniqueNetEvSeg = unique(netEvSeg);
nUnique = length(uniqueNetEvSeg);

for condInd = 1:nUnique
    
    %first ind 
    firstCondInd = find(netEvSeg == uniqueNetEvSeg(condInd),1,'first');
    
    %get data
    tempDFF = imTrials{firstCondInd}.imaging.dFFTraces;
    tempDGR = imTrials{firstCondInd}.imaging.dGRTraces;
    tempDataFrames = imTrials{firstCondInd}.imaging.dataFrames;
    tempDFFPCA = imTrials{firstCondInd}.imaging.dFFPCA;
    tempDGRPCA = imTrials{firstCondInd}.imaging.dGRPCA;
    
    %store
    for trialInd = 1:length(imTrials)
        if netEvSeg(trialInd) == uniqueNetEvSeg(condInd)
            imTrials{trialInd}.imaging.dataFrames = tempDataFrames;
            imTrials{trialInd}.imaging.dFFTraces = tempDFF;
            imTrials{trialInd}.imaging.dGRTraces = tempDGR;
            imTrials{trialInd}.imaging.dFFPCA = tempDFFPCA;
            imTrials{trialInd}.imaging.dGRPCA = tempDGRPCA;
        end
    end
end

dataCellLeft = getTrials(imTrials,'maze.leftTrial==1');
dataCellRight = getTrials(imTrials,'maze.leftTrial==0');
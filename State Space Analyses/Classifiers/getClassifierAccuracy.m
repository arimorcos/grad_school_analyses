function accuracy = getClassifierAccuracy(nTrials,nBins,dFFTraces,PCATraces,...
    leftTurns,rightTurns,usePCs)

%initialize accuracy
classifierOut = zeros(nTrials,nBins);

%cycle through each bin
for i = 1:nBins %for each bin
    
    %get left/right data
    if usePCs
        leftData = squeeze(PCATraces(:,i,leftTurns));
        rightData = squeeze(PCATraces(:,i,rightTurns));
    else
        leftData = squeeze(dFFTraces(:,i,leftTurns));
        rightData = squeeze(dFFTraces(:,i,rightTurns));
    end
    

    leftDataSum = nansum(leftData,2);
    rightDataSum = nansum(rightData,2);
    for j = 1:nTrials %for each trial
        
        %exclude current trial from left/right turns
%         tempLeft = leftTurns(leftTurns ~= j);
%         tempRight = rightTurns(rightTurns ~= j);
        tempLeft = leftTurns ~= j;
        tempRight = rightTurns ~= j;
        
        %get left/right data
        if usePCs
            testData = PCATraces(:,i,j);
        else
            testData = dFFTraces(:,i,j);
        end
        
        %take mean position
%         leftMeanOld = nanmean(leftData(:,tempLeft),2);
%         rightMeanOld = nanmean(rightData(:,tempRight),2);
        if any(~tempLeft)
            leftMean = nansum([leftDataSum,-leftData(:,~tempLeft)],2)/sum(tempLeft);
        else
            leftMean = leftDataSum/sum(tempLeft);
        end
        if any(~tempRight)
            rightMean = nansum([rightDataSum,-rightData(:,~tempRight)],2)/sum(tempRight);
        else
            rightMean = rightDataSum/sum(tempRight);
        end
        
        %get distance to mean left/right
        leftDist = calcEuclidianDist(leftMean,testData);
        rightDist = calcEuclidianDist(rightMean,testData);
        
        %store
        if (leftDist < rightDist && any(j == leftTurns)) ||...
                (leftDist > rightDist && any(j == rightTurns)) % if closer to left and left turn or if closer to right and right turn
            classifierOut(j,i) = 1; %mark as correct
        elseif leftDist == rightDist %if equidistant, guess
            classifierOut(j,i) = randi([0 1]); 
        elseif isnan(leftDist) || isnan(rightDist)
            classifierOut(j,i) = NaN; 
        end %otherwise leave as 0 (incorrect
        
    end
    
end

%get number of nan in each column
nNonNaNTrials = size(classifierOut,1) - sum(isnan(classifierOut));

%get percent correct for each bin
accuracy = nansum(classifierOut)./nNonNaNTrials;
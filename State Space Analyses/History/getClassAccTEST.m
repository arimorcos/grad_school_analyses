function acc = getClassAccTEST(traces,realClass)

for binInd = 1:size(traces,2)
    
    for testTrial = 1:size(traces,3)
        
        %get training trials
        trainingInd = setdiff(1:size(traces,3),testTrial);
        trainTraces = traces(:,:,trainingInd);
        
        %calculate mean for class 1 
        trialBinMean(1) = mean(trainTraces(:,binInd,realClass(trainingInd)==0),3);
        trialBinMean(2) = mean(trainTraces(:,binInd,realClass(trainingInd)==1),3);
        
        %calculate distance 
        trialBinDist(1) = abs(traces(:,binInd,testTrial) - trialBinMean(1));
        trialBinDist(2) = abs(traces(:,binInd,testTrial) - trialBinMean(2));
        
        %find which one is lower
        if trialBinDist(1) < trialBinDist(2)
            guess(testTrial,binInd) = 0;
            fprintf('%.5f < %.5f\n',trialBinDist(1),trialBinDist(2));
        else
            guess(testTrial,binInd) = 1;
            fprintf('%.5f < %.5f\n',trialBinDist(2),trialBinDist(1));
        end
        
    end
end

%calculate accuracy 
realClass = repmat(realClass,1,size(traces,2));

correct = realClass == guess;

acc = 100*sum(correct)./size(traces,3);

if any(acc < 30)
    keyboard;
end
        

% function acc = getClassAccTest(traces,realClass)
% 
% %get nTrials, nBins
% [nNeurons, nBins, nTrials] = size(traces);
% 
% %get unique classes
% classes = unique(realClass);
% nClasses = length(classes);
% 
% for testTrial = 1:nTrials
%     
%     %get training trials
%     trainingInd = setdiff(1:size(traces,3),testTrial);
%     trainTraces = traces;
%     trainTraces(:,:,testTrial) = [];
%     tempClass = realClass;
%     tempClass(testTrial) = [];
%     
%     %loop through each class and calculate mean
%     for classInd = 1:nClasses
%         %calculate mean for class
%         trialBinMean(classInd,:) = mean(trainTraces(:,:,tempClass==classes(classInd)),3);
%         
%         %calculate distances
%         trialDistances(classInd,:) = arrayfun(@(binInd) calcEuclideanDist(...
%             traces(:,binInd,testTrial),trialBinMean(classInd,binInd)),1:nBins);
%     end
% 
%     %find which one is lower
%     [~,guessInd] = min(trialDistances);
%     classGuess(testTrial,:) = classes(guessInd);
% end
% 
% 
% %% calculate and plot
% %calculate accuracy 
% realClass = repmat(realClass,1,size(traces,2));
% 
% correct = realClass == classGuess;
% 
% acc = 100*sum(correct)./size(traces,3);
% 
% if any(acc < 30)
%     keyboard;
% end
% 
% histogram(acc,20);
        
        
        
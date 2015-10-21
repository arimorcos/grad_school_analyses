% %% upcoing turn 
fileList = dir2cell('*upcomingTurn_deconv*');

%initialize 
peakAcc = [];
pValue = [];
meanShuffleAcc = [];

%loop through each file 
for file = 1:length(fileList)

    %load file 
    load(fileList{file});
    
    %get peak accuracy
    tempAcc = max(accuracy,[],2);
    peakAcc = cat(1,peakAcc,tempAcc);
    
    %get peak accuracy of shuffle
    peakShuffleAcc = squeeze(max(shuffleAccuracy,[],2));
    meanShuffleAcc = cat(1,meanShuffleAcc,peakShuffleAcc);
    
    %get significance 
%     tempPVal = arrayfun(@(x) getPValFromShuffle(tempAcc(x),peakShuffleAcc(:,x),true),...
%         1:length(tempAcc));
%     pValue = cat(2,pValue,tempPVal);
end

save('allNeurons_upcomingTurn_peakAcc_deconv','peakAcc','pValue','meanShuffleAcc');
% save('allNeurons_upcomingTurn_peakAcc_deconv','peakAcc');

%% net evidence 
% fileList = dir2cell('*netEvSVR_deconv*');
% 
% %initialize 
% netEvCorr = [];
% pValue = [];
% meanShuffleCorr = [];
% 
% %loop through each file 
% for file = 1:length(fileList)
%     
%     dispProgress('Calculating %d/%d',file,file,length(fileList));
% 
%     %load file 
%     load(fileList{file});
%     
%     %get peak accuracy
%     nCells = length(classifierOut);
%     
%     tempCorr = [];
%     tempShuffleCorr = [];
%     tempPVal = [];
%     for cell = 1:nCells
%         [tempCorr(cell),shuffleCorr] = getNetEvCorrCoef(classifierOut{cell},true);
%         tempShuffleCorr(cell) = shuffleCorr(1);
%         tempPVal(cell) = getPValFromShuffle(tempCorr(cell),shuffleCorr);        
%     end
%     netEvCorr = cat(1,netEvCorr,tempCorr');
%     pValue = cat(1,pValue,tempPVal');
%     meanShuffleCorr = cat(1,meanShuffleCorr,tempShuffleCorr');
% end
% 
% save('allNeurons_netEv_peakAcc','netEvCorr','pValue','meanShuffleCorr');
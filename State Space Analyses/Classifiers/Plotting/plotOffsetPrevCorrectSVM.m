function plotOffsetPrevCorrectSVM(folder, fileStr)
%plotOffsetPrevCorrectSVM.m Plots the output of the offsetPrevCorrectSVM
%which offsets the correct trials relative to error trials in time
%
%INPUTS
%accuracy - 1 x nOffsets cell array of accuracies
%shuffleAccuracy - 1 x nOffsets cell array of shuffled accuracies 
%offsets - 1 x nOffsets array of offset times in seconds
%
%ASM 7/15

%% process 
%get list of files in folder 
[allNames, ~, ~, ~, isDirs] = dir2cell(folder);
files = allNames(~isDirs);

%match string 
matchFiles = files(~cellfun(@isempty,regexp(files,fileStr)));

%get nFiles
nFiles = length(matchFiles);

%loop through each file and create array 
accuracy = cell(nFiles,1);
shuffleAccuracy = cell(nFiles,1);
offsets = cell(nFiles,1);
for fileInd = 1:nFiles
    currFileData = load(fullfile(folder,matchFiles{fileInd}));
    accuracy{fileInd} = currFileData.accuracy;
    shuffleAccuracy{fileInd} = currFileData.shuffleAccuracy;
    offsets{fileInd} = currFileData.offsets;
end

peakAcc = cell(nFiles,1);
for file = 1:nFiles
    %get nOffsets
    nOffsets = length(offsets{file});
    
    %calculate nSTD above shuffle for each
    peakAcc{file} = nan(nOffsets,1);
    for i = 1:nOffsets
        
        %get median and std of shuffled accuracy
        shuffleMed = median(shuffleAccuracy{file}{i});
        shuffleSTD = std(shuffleAccuracy{file}{i});
        
        %get nSTD for accuracy
        nSTDAcc = (accuracy{file}{i}' - shuffleMed)./shuffleSTD;
        peakAcc{file}(i) = mean(nSTDAcc(1:10));
        
    end
end
%% plot
figH = figure;
axH = axes;
hold(axH, 'on');

catAcc = cat(2,peakAcc{:})';
boxplot(catAcc);
axH.XTickLabel = offsets{1};
% 
% colors = distinguishable_colors(nFiles);
% for file = 1:nFiles
%     %plot
%     plotH = plot(offsets{file},peakAcc{file});
%     plotH.Marker = 'o';
%     plotH.Color = colors(file,:);
%     plotH.LineWidth = 2;
% end

%beautify
beautifyPlot(figH, axH);

%label
axH.XLabel.String = 'Correct vs. Error Trial Offset (s)';
axH.YLabel.String = 'nSTD Above Chance';
axH.Title.String = 'Previous Reward Peak Classification Accuracy';

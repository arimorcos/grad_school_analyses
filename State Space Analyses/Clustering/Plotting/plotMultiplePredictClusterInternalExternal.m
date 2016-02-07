function handles = plotMultiplePredictClusterInternalExternal(folder,fileStr)
%plotMultipleClassifiersFromFolder.m Plots multiple classifiers based on a
%specific folder path 
%
%INPUTS 
%folder - path to folder 
%fileStr - string to match files to 
%
%OUTPUTS
%handles - structure of handles 
%
%ASM 8/15

showSig = true;

%get list of files in folder 
[allNames, ~, ~, ~, isDirs] = dir2cell(folder);
files = allNames(~isDirs);

%match string 
matchFiles = files(~cellfun(@isempty,regexp(files,fileStr)));
nFiles = length(matchFiles);

%loop through each file and create array 
barInfo = nan(6,4,nFiles);
for fileInd = 1:nFiles
    currFileData = load(fullfile(folder,matchFiles{fileInd}));
    out = currFileData.out;
    barInfo(:,:,fileInd) = cat(1,out.noInformationAcc,out.externalAcc,out.internalAcc,out.bothAcc)';
end

%multiply by 100 
barInfo = 100*barInfo;

%take mean and sem 
meanBarInfo = mean(barInfo,3);
semBarInfo = calcSEM(barInfo,3);

%create figure 
figH = figure; 
axH = axes;


%create barplot 
% barH = bar(meanBarInfo);
barH = barwitherr(semBarInfo,meanBarInfo);
colors = lines(5);
colors(3,:) = [];
for i = 1:4
    barH(i).FaceColor = colors(i,:);
end

% add significance 
if showSig
    numCues = size(barInfo, 1);
    nBars = 4;
    delta = 0.14;
    for cue = 1:numCues
        positions = [cue - 2*delta, cue - 1*delta,...
            cue + 1*delta, cue + 2*delta];
        groups = {};
        pVal = [];
        for group_1 = 1:4
            for group_2 = group_1+1:4
%             for group_2 = 4:4
                if group_1 == group_2 
                    continue
                end
                
                groups = cat(1,groups,positions([group_1, group_2]));
                
                [~,tempPVal] = ttest2(squeeze(barInfo(cue,group_1,:)),...
                    squeeze(barInfo(cue,group_2,:)));
                pVal = cat(1,pVal,tempPVal);
                
%                 if group_1== 1 && group_2 == 2
%                     fprintf('Cue: %d, chance/cue sig: %.3e\n',cue,tempPVal);
%                 end
                if group_1== 2 && group_2 == 3
                    fprintf('Cue: %d, cue/internal sig: %.3e\n',cue,tempPVal);
                end
                
            end
        end
        
        sigstar(groups,pVal,false,false);
    end
end

%beautify
beautifyPlot(figH,axH);

%label 
axH.XLabel.String = 'Cue number';
axH.YLabel.String = 'Prediction accuracy';

%legend
% legH = legend('No information','External only','Internal only','Internal + External');
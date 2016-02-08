function plotMultipleClusteredBehavioralDistributionBreakCorr(folder,fileStr)
%plotMultipleClusteredBehavioralDistribution.m Plots multiple beahvioral
%distributions for clusters
%
%INPUTS
%folder - folder to search in
%fileStr - file string to match
%
%ASM 6/15

%get list of files in folder
[allNames, ~, ~, ~, isDirs] = dir2cell(folder);
files = allNames(~isDirs);

%match string
matchFiles = files(~cellfun(@isempty,regexp(files,fileStr)));

%get nDset
nDatasets = length(matchFiles);

%loop through each file and create array
allOut = cell(nDatasets,1);
allOutBreakCorr = cell(nDatasets,1);
for fileInd = 1:nDatasets
    currFileData = load(fullfile(folder,matchFiles{fileInd}));
    allOut{fileInd} = currFileData.out;
    allOutBreakCorr{fileInd} = currFileData.outBreakCorr;
end



if iscell(allOut{1})
    for i = 1:6
        %get all summedDiff and shuffleDiff
        allSummedDiff{i} = cellfun(@(x) x{i}.summedDiff,allOut);
        allSummedDiffBreakCorr{i} = cellfun(@(x) x{i}.summedDiff,allOutBreakCorr);
        allConfInt{i} = nan(nDatasets,2);
        allMedians{i} = nan(nDatasets,1);
        allConfIntBreakCorr{i} = nan(nDatasets,2);
        allMediansBreakCorr{i} = nan(nDatasets,1);
        for dSet = 1:nDatasets
            tempConfInt = prctile(allOut{dSet}{i}.shuffleDiff,[0.5 99.5]);
            allMedians{i}(dSet) = median(allOut{dSet}{i}.shuffleDiff);
            allConfInt{i}(dSet,:) = abs(bsxfun(@minus,allMedians{i}(dSet),tempConfInt));
            
            tempConfInt = prctile(allOutBreakCorr{dSet}{i}.shuffleDiff,[0.5 99.5]);
            allMediansBreakCorr{i}(dSet) = median(allOutBreakCorr{dSet}{i}.shuffleDiff);
            allConfIntBreakCorr{i}(dSet,:) = abs(bsxfun(@minus,allMediansBreakCorr{i}(dSet),tempConfInt));
        end
    end
    
else
    %get all summedDiff and shuffleDiff
    allSummedDiff = cellfun(@(x) x.summedDiff,allOut);
    allSummedDiffBreakCorr = cellfun(@(x) x.summedDiff,allOutBreakCorr);
    allConfInt = nan(nDatasets,2);
    allMedians = nan(nDatasets,1);
    allConfIntBreakCorr = nan(nDatasets,2);
    allMediansBreakCorr = nan(nDatasets,1);
    for dSet = 1:nDatasets
        tempConfInt = prctile(allOut{dSet}.shuffleDiff,[0.5 99.5]);
        allMedians(dSet) = median(allOut{dSet}.shuffleDiff);
        allConfInt(dSet,:) = abs(bsxfun(@minus,allMedians(dSet),tempConfInt));
        
        tempConfInt = prctile(allOutBreakCorr{dSet}.shuffleDiff,[0.5 99.5]);
        allMediansBreakCorr(dSet) = median(allOutBreakCorr{dSet}.shuffleDiff);
        allConfIntBreakCorr(dSet,:) = abs(bsxfun(@minus,allMediansBreakCorr(dSet),tempConfInt));
    end
end

%% plot summed diff
show_summed_diff = false;

which_cue = 5;

if show_summed_diff
    
    %create figure
    figH = figure;
    axH = axes;
    hold(axH,'on');
    
    %generate colors
    colors = lines(2);
    
    %plot scatter
    scatH = scatter(1:nDatasets,allSummedDiff{which_cue},150,colors(1,:),'filled');
    scatHBreakCorr = scatter(1:nDatasets,allSummedDiffBreakCorr{which_cue},150,colors(2,:),'filled');
    
    %plot errorbars
    for dSet = 1:nDatasets
        errH = errorbar(dSet-0.2,allMedians{which_cue}(dSet),...
            allConfInt{which_cue}(dSet,1),allConfInt{which_cue}(dSet,2));
        errH.Color = colors(1,:);
        errH.LineWidth = 3;
        
        errH = errorbar(dSet+0.2,allMediansBreakCorr{which_cue}(dSet),...
            allConfIntBreakCorr{which_cue}(dSet,1),allConfIntBreakCorr{which_cue}(dSet,2));
        errH.Color = colors(2,:);
        errH.LineWidth = 3;
    end
    
    %beautify
    beautifyPlot(figH,axH);
    
    %label
    axH.XTick = [];
    axH.YLabel.String = 'Summed difference from uniform';
    axH.XLabel.String = 'Dataset';
    axH.XLim = [-nDatasets 2*nDatasets];
end
%% plot diff

show_rel_diff = true;
if show_rel_diff
    
    % concatenate 
    reg_summed_diff = cat(2, allSummedDiff{:});
    break_corr_summed_diff = cat(2, allSummedDiffBreakCorr{:});
    
    % get sig 
    p_val = nan(6, 1);
    for i = 1:6 
        [~, p_val(i)] = ttest2(reg_summed_diff(:, i), break_corr_summed_diff(:, i));
    end
    
    %normalize 
    break_corr_summed_diff = break_corr_summed_diff./reg_summed_diff;
    reg_summed_diff = reg_summed_diff./reg_summed_diff;
    
    %calculate error and concatenate 
    mean_summed_diff = cat(1, mean(reg_summed_diff), mean(break_corr_summed_diff));
    sem_summed_diff = cat(1, calcSEM(reg_summed_diff), calcSEM(break_corr_summed_diff));
    
    figH = figure;
    axH = axes;
    
    x_vals = repmat([1; 2], 1, 6);
    x_vals(2,:) = x_vals(2,:) + 0.1*randn(size(x_vals(2,:)));
    errH = errorbar(x_vals, mean_summed_diff, sem_summed_diff);
    
    beautifyPlot(figH, axH);
    
    %label
    axH.XTick = [1, 2];
    axH.XTickLabel = {'Normal','Break correlation'};
    axH.XTickLabelRotation = 0;
    axH.YLabel.String = 'Normalized summed difference from uniform';
    
    %legend 
    legH = legend({'Cue 1', 'Cue 2', 'Cue 3', 'Cue 4', 'Cue 5', 'Cue 6'},...
        'Location', 'SouthWest');
end
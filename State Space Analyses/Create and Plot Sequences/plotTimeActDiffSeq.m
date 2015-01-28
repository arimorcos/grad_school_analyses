function figHandle = plotTimeActDiffSeq(dataCell,normInd,conditions)
%plotTimeActDiffSeq.m Finds the difference in peak activity time for
%different conditions and plots
%
%INPUTS
%dataCell - dataCell containing imaging data
%normInd - normalize each individually
%
%OUTPUTS
%figHandle - figure handle
%
%ASM 1/14

if length(conditions) < 2 || isempty(conditions)
    error('Must provide at least 2 conditions');
end

%get nCond
nCond = length(conditions);

%initialize traces
traces = cell(1,nCond);
usedSortOrder = cell(1,nCond);
unsortedTraces = [];

%loop through and create sequences
for i = 1:nCond
    
    %determine sortOrder
    sortOrder = usedSortOrder{1};
    
    %get sequence
    [traces{i},bins,unSortTrace,usedSortOrder{i}] = makeSeqSubset(dataCell,conditions{i},sortOrder,[]);
    
    %cat unsorted trace
    unsortedTraces = cat(2,unsortedTraces,unSortTrace);
    
end

%normalize cells individually
if ischar(normInd) && strcmpi(normInd,'cells')
    normTraces = cellfun(@(x) bsxfun(@rdivide,x,max(x,[],2)),traces,'UniformOutput',false);
%     normInd = true;
elseif ischar(normInd) && strcmpi(normInd,'zscore')
    normTraces = cellfun(@zScoreTraces,traces,'UniformOutput',false);
elseif normInd == true
    %normalize traces
    normTraces = normalizeTraces(traces,normInd,unsortedTraces,usedSortOrder);
%     normInd = true;
else
    normTraces = traces;
%     normInd = false;
end

%get time of peak firing
maxInds = zeros(size(traces{1},1),nCond);
for condInd = 1:nCond
    [~,maxInds(:,condInd)]=max(normTraces{condInd},[],2);
end

%find difference from time of peak firing
peakDiff = bsxfun(@minus,maxInds,maxInds(:,1));
% peakDiff = abs(peakDiff);

%plot
figure;
hold on;
colors = jet(nCond);
for condInd = 1:nCond
    scatter(1:size(traces{1},1),peakDiff(:,condInd),'MarkerFaceColor',colors(condInd,:));
end
scatter(1:size(traces{1},1),mean(peakDiff(:,2:end),2),'MarkerFaceColor','k');
xlabel('Cell #','FontSize',30);
ylabel('abs(Condition 1 Peak - Condition Peak)','FontSize',30)
legend(conditions,'Location','Best');
set(gca,'FontSize',20);

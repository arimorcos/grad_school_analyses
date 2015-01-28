function figHandle = makeLeftRightSeq(dataCell,normInd,conditions,sortFirst,gCells,axToPlot)
%makeLeftRightSeq.m Creates sequence by sorting data by time of peak activity
%
%INPUTS
%dataCell - dataCell containing imaging data
%normInd - normalize each individually
%conditions - 1 x nCond cell array of conditions
%sortFirst - should sort according to first
%
%OUTPUTS
%figHandle - figure handle
%
%ASM 1/14
% shouldZScore = true;

if nargin < 6 
    axToPlot = [];
end
if nargin < 5 
    gCells = [];
end
if nargin < 4 || isempty(sortFirst)
    sortFirst = false;
end
if nargin < 3 || isempty(conditions)
    %set conditions
    conditions = {'maze.crutchTrial == 0;result.correct == 1',...
        'maze.crutchTrial == 0;result.correct==1;result.leftTurn==1',...
        'maze.crutchTrial == 0;result.correct==1;result.leftTurn==0'};
    conditions = conditions([2 3 1]);
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
    if ~sortFirst || i == 1
        sortOrder = [];
    else
        sortOrder = usedSortOrder{1};
    end
    
    %get sequence
    [traces{i},bins,unSortTrace,usedSortOrder{i}] = makeSeqSubset(dataCell,conditions{i},sortOrder,gCells);
    
    %cat unsorted trace
    unsortedTraces = cat(2,unsortedTraces,unSortTrace);
    
end

%normalize cells individually
colorLab = [];
if ischar(normInd) && strcmpi(normInd,'cells')
    allTraces= cat(2,traces{:});
    maxTraces = max(allTraces,[],2);
%     normTraces = cellfun(@(x) bsxfun(@rdivide,x,max(x,[],2)),traces,'UniformOutput',false);
    normTraces=cellfun(@(x) bsxfun(@rdivide,x,maxTraces),traces,'UniformOutput',false);
    normInd = true;
elseif ischar(normInd) && strcmpi(normInd,'zscore')
    normTraces = cellfun(@zScoreTraces,traces,'UniformOutput',false);
    figHandle = plotSequencesZScored(normTraces,bins,conditions,[0 3]);
    return;
elseif normInd == true
    %normalize traces
    normTraces = normalizeTraces(traces,normInd,unsortedTraces,usedSortOrder);
    normInd = true;
else
    normTraces = traces;
    normInd = false;
end

%plot
figHandle = plotSequences(normTraces,bins,conditions,normInd,colorLab,axToPlot);



function [pops,conds] = findOverlappingPopulations(dataCell,conds,varargin)
%findOverlappingPopulations.m Finds overlapping or non-overlapping
%populations for the conditions specified in conds. Requires thresholded
%traces
%
%INPUTS
%dataCell - dataCell containing thresholded imaging data
%conds - 1 x nConds cell array of conditions to compare
%
%VARIABLE INPUTS
%activeThresh - fraction of trials in a condition in which a cell must be
%   active to count. Default is 0.5
%elimInactive - eliminat inactive cells
%
%OUTPUTS
%pops - nCells x nConds logical of whether cell is active during that
%   condition or not
%conds - 1 x nConds cell array of conditions compared
%
%ASM 11/14


%process varargin
activeThresh = 0.5;
elimInactive = true;

%process varargin
if nargin > 1 || ~isempty(varargin)
    if isodd(length(varargin))
        error('Must provide a name and value for each argument');
    end
    for argInd = 1:2:length(varargin) %for each argument
        switch lower(varargin{argInd})
            case 'activethresh'
                activeThresh = varargin{argInd+1};
            case 'eliminactive'
                elimInactive = varargin{argInd+1};
        end
    end
end

%subset to imaging trials
imTrials = getTrials(dataCell,'imaging.imData==1');

%get nConds
nConds = length(conds);

%get traces
[~,traces] = catBinnedTraces(imTrials);

%get nCells
nCells = size(traces,1);

%initialize pops
pops = false(nCells,nConds);

%loop through each condition
for condInd = 1:nConds
    
    %find trial indices which match
    matchInd = findTrials(imTrials,conds{condInd});
    
    %subset traces
    matchTraces = traces(:,:,matchInd);
    
    %get total trials and matchThresh
    subTrials = sum(matchInd);
    
    %binarize each cells activity on each trial as active or inactive
    subActive = squeeze(any(matchTraces,2)); %nCells x nTrials where each value is whether cell is active or inactive on that particular trial
    
    %calculate fraction of trials each cell is active for
    fracActive = sum(subActive,2)/subTrials;
    
    %set cells whose fracActive is greater than activeThresh to true
    pops(:,condInd) = fracActive >= activeThresh;
    
    
end

%find inactive cells
if elimInactive 
    inactiveAll = ~any(pops,2);
    pops(inactiveAll,:) = [];
end

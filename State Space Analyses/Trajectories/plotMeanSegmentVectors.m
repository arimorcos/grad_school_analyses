function plotMeanSegmentVectors(segVectors,whichFactors,toExclude)
%plotMeanSegmentVectors.m Plots mean segment vectors for each unique
%condition
%
%INPUTS
%segVectors - table output by getSegVectors
%whichFactors - which factors to plot
%toExclude - variables to exclude in filtering
%
%ASM 1/15

if nargin < 3
    toExclude = [];
else
    assert(ischar(toExclude) || iscell(toExclude),'Must provide toExclude as a cell or a string');
    if ~iscell(toExclude)
        toExclude = {toExclude};
    end
end

%condition check
%check that segVectors is a table
assert(istable(segVectors),'segVectors must be a table');

%check that varToUse matches variable in table
for toCheck = toExclude
    assert(any(strcmp(toCheck,segVectors.Properties.VariableNames)),...
        '%s is not a valid variable name',toCheck);
end


%check whichFactors
if length(whichFactors) == 2
    whichFactors(3) = min(length(segVectors{1,'vector'}{1}),whichFactors(2) + 1);
    view3D = false;
else
    view3D = true;
end


%remove column of excluded variables
for i = 1:length(toExclude)
    segVectors.(toExclude{i}) = [];
end

%extract vector column and remove
vectors = segVectors.vector;
segVectors.vector = [];

%get nTrials
nTrials = size(segVectors,1);

%find unique conditions
uniqueConds = unique(segVectors,'rows');
nConds = size(uniqueConds,1);

%get remaining variable names
varNames = segVectors.Properties.VariableNames;

%loop through each condition and generate mean vectors
meanVectors = nan(length(whichFactors),nConds);
for condInd = 1:nConds
    
    %find matching indices
    indMatch = true(nTrials,1); %assume all true
    for var = varNames
        indMatch(segVectors.(var{1}) ~= uniqueConds{condInd,var{1}}) = false; %remove if doesn't match condition
    end
    
    %extract vectors
    tempVectors = cat(2,vectors{indMatch});
    
    %get mean vector 
    meanVectors(:,condInd) = mean(tempVectors(whichFactors,:),2);
    
end

%create figure 
figH = figure;
axH = axes;
hold(axH,'on');

%get colors
colors = distinguishable_colors(nConds);

%loop through and plot each vector 
plotH = gobjects(nConds);
for condInd = 1:nConds
    
    %plot 
    plotH(condInd) = plot3([0 meanVectors(1,condInd)], [0 meanVectors(2,condInd)],...
        [0 meanVectors(3,condInd)]);
    
    %set line color
%     plotH(condInd).Color = colors(condInd,:);
    if uniqueConds{condInd,'segID'}
        plotH(condInd).Color = 'r';
    else
        plotH(condInd).Color = 'b';
    end
    
    %add arrow
%     line2arrow(plotH(condInd));
    
end

%determine view
if view3D
    view(3);
else
    view(2);
end

%label axes
axH.XLabel.String = sprintf('Factor %d',whichFactors(1));
axH.YLabel.String = sprintf('Factor %d',whichFactors(2));
if length(whichFactors) == 3
    axH.ZLabel.String = sprintf('Factor %d',whichFactors(3));
end

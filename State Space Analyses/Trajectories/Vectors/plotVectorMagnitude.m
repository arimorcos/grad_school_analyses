function plotVectorMagnitude(segVectors,groupBy)
%plotMeanSegmentVectors.m Plots mean segment vectors for each unique
%condition
%
%INPUTS
%segVectors - table output by getSegVectors
%groupBy - names of variables to group according to 
%
%ASM 2/15

%condition check
%check that segVectors is a table
assert(istable(segVectors),'segVectors must be a table');

%process groupBy
if nargin < 2
    groupBy = segVectors.Properties.VariableNames;
else
    assert(ischar(groupBy) || iscell(groupBy),'Must provide groupBy as a cell or a string');
    if ~iscell(groupBy)
        groupBy = {groupBy};
    end
end

%extract vector column and remove
vectors = segVectors.vector;

%remove unnecessary variables
segVectors = segVectors(:,groupBy);

%get nTrials
nTrials = size(segVectors,1);

%find unique conditions
uniqueConds = unique(segVectors,'rows');
nConds = size(uniqueConds,1);

%get remaining variable names
varNames = segVectors.Properties.VariableNames;

%loop through each condition and generate mean vectors
meanMag = nan(1,nConds);
semMag = nan(1,nConds);
for condInd = 1:nConds
    
    %find matching indices
    indMatch = true(nTrials,1); %assume all true
    for var = varNames
        indMatch(segVectors.(var{1}) ~= uniqueConds{condInd,var{1}}) = false; %remove if doesn't match condition
    end
    
    %get magnitude
    getMagnitude = @(x) sqrt(sum(x.^2));
    vectorMags = cell2mat(cellfun(getMagnitude, vectors(indMatch), 'UniformOutput', false));

    %compute mean and sem of each
    meanMag(condInd) = nanmean(vectorMags);
    semMag(condInd) = calcSEM(vectorMags);
end

%create figure 
figure;
axH = axes;
hold(axH,'on');

%create bar chart 
barH = barwitherr(semMag, meanMag);
barH.error.LineWidth = 2;

%set prober tick labels 
strLabels = convertTableToLegendString(uniqueConds);
axH.XTick = 1:length(strLabels);
axH.XTickLabel = strLabels;
axH.XTickLabelRotation = -45;

%label axes 
axH.YLabel.String = 'Vector Magnitude';

end
function plotVectorAngleVsGamma(segVectors,groupBy,whichFactors)
%plotVectorMagVsGamma.m Plots the vector magnitude vs. the distance to the
%hyperplane
%
%INPUTS
%segVectors - table output by getSegVectors
%colorBy - names of variables to color by
%whichFactors - which factors to calculate magnitude on. Default is all
%
%ASM 2/15

%condition check
%check that segVectors is a table
assert(istable(segVectors),'segVectors must be a table');

%process groupBy
if nargin < 2 || isempty(groupBy)
    groupBy = [];
else
    assert(ischar(groupBy) || iscell(groupBy),'Must provide groupBy as a cell or a string');
    if ~iscell(groupBy)
        groupBy = {groupBy};
    end
end

%extract vector column and remove
vectors = segVectors.vector;

%get gamma
gamma = segVectors.gamma;

%get all the other variables
segVectors = segVectors(:,groupBy);

%whichFactors
if nargin < 3 || isempty(whichFactors)
    whichFactors = 1:length(vectors{1});
end

%crop factors
vectors = cellfun(@(x) x(whichFactors),vectors,'UniformOutput',false);

%get nTrials
nTrials = size(segVectors,1);

%create function for magnitude
getMagnitude = @(x) sqrt(sum(x.^2));

%get refVec
refVec = ones(size(vectors{1}));

%calculate the angle of each vector
getAngle = @(x,y) rad2deg(acos(dot(x,y)/(getMagnitude(x)*getMagnitude(y))));
vectorAngles = cell2mat(cellfun(@(x) getAngle(x,refVec),vectors,'UniformOutput',false));

%generate groups
if ~isempty(groupBy)
    
    %find unique conditions
    uniqueConds = unique(segVectors,'rows');
    nConds = size(uniqueConds,1);
    
    %get remaining variable names
    varNames = segVectors.Properties.VariableNames;
    
    groups = nan(nTrials,1);
    for condInd = 1:nConds
        %find matching indices
        indMatch = true(nTrials,1);
        for var = varNames
            indMatch(segVectors.(var{1}) ~= uniqueConds{condInd,var{1}}) = false; %remove if doesn't match condition
        end
        groups(indMatch) = condInd;
    end
else
    nConds = 1;
    groups = ones(nTrials,1);
end

%%%%%%%%%%%%% plot %%%%%%%%%%%%%%%%%%%%%%%%% 

%create figure 
figure;
axH = axes;
hold(axH,'on');
 
%create scatter plot 
scatH = gscatter(gamma,vectorAngles,groups,[],[],[],'false');

%get distinguishable colors
colors = distinguishable_colors(nConds);

%modify each plot
for condInd = 1:nConds
    scatH(condInd).MarkerSize = 25;
    scatH(condInd).MarkerFaceColor = colors(condInd,:);
end

if ~isempty(groupBy)
    %get legend entries
    strLabels = convertTableToLegendString(uniqueConds);
    
    %create legend 
    legend(scatH,strLabels,'Location','Best');
end

%label axes 
axH.YLabel.String = 'Vector Angle';
axH.XLabel.String = 'Distance to Hyperplane';
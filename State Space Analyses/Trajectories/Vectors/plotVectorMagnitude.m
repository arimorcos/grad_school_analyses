function plotVectorMagnitude(segVectors,groupBy,whichFactors)
%plotMeanSegmentVectors.m Plots mean segment vectors for each unique
%condition
%
%INPUTS
%segVectors - table output by getSegVectors
%groupBy - names of variables to group according to 
%whichFactors - which factors to calculate angle on. Default is all 
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

%whichFactors
if nargin < 3 || isempty(whichFactors)
    whichFactors = 1:length(vectors{1});
end

%crop factors 
vectors = cellfun(@(x) x(whichFactors),vectors,'UniformOutput',false);

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
vectorMags = cell(1,nConds);
for condInd = 1:nConds
    
    %find matching indices
    indMatch = true(nTrials,1); %assume all true
    for var = varNames
        indMatch(segVectors.(var{1}) ~= uniqueConds{condInd,var{1}}) = false; %remove if doesn't match condition
    end
    
    %get magnitude
    getMagnitude = @(x) sqrt(sum(x.^2));
    vectorMags{condInd} = cell2mat(cellfun(getMagnitude, vectors(indMatch), 'UniformOutput', false));

    %compute mean and sem of each
    meanMag(condInd) = nanmean(vectorMags{condInd});
    semMag(condInd) = calcSEM(vectorMags{condInd});
end

%calculate statistics
statsPairs = nan(nchoosek(nConds,2),2);
pairPVal = nan(nchoosek(nConds,2),1);
pairInd = 1;
for firstCond = 1:nConds
    for secondCond = firstCond+1:nConds
        %store pair 
        statsPairs(pairInd,1) = firstCond;
        statsPairs(pairInd,2) = secondCond;
        
        %calc pVal 
        [~,pairPVal(pairInd)] = ttest2(vectorMags{firstCond},vectorMags{secondCond});
        
        %increment pairInd
        pairInd = pairInd + 1;
    end
end

%create figure 
figure;
axH = axes;
hold(axH,'on');

%create bar chart 
barH = barwitherr(semMag, meanMag);
barH.error.LineWidth = 2;

%add statistics 
criteria = [0.05 1e-2 1e-3];
% criteria = criteria/sqrt(length(pairPVal)); %bonferonni correct
statsH = sigstar(num2cell(statsPairs,2),pairPVal,[],[],criteria);

%set prober tick labels 
strLabels = convertTableToLegendString(uniqueConds);
axH.XTick = 1:length(strLabels);
axH.XTickLabel = strLabels;
axH.XTickLabelRotation = -45;

%label axes 
axH.YLabel.String = 'Vector Magnitude';

end
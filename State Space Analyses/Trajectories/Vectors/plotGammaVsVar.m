function plotGammaVsVar(segVectors,groupBy)
%plotGammaVsVar.m Plots mean gamma for each unique
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

%extract gamma
gamma = segVectors.gamma;

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
meanGamma = nan(1,nConds);
semGamma = nan(1,nConds);
condGamma = cell(1,nConds);
for condInd = 1:nConds
    
    %find matching indices
    indMatch = true(nTrials,1); %assume all true
    for var = varNames
        indMatch(segVectors.(var{1}) ~= uniqueConds{condInd,var{1}}) = false; %remove if doesn't match condition
    end
    
    %get gamma 
    condGamma{condInd} = gamma(indMatch);
    
    %calc mean and sem
    meanGamma(condInd) = nanmean(condGamma{condInd});
    semGamma(condInd) = calcSEM(condGamma{condInd});
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
        [~,pairPVal(pairInd)] = ttest2(condGamma{firstCond},condGamma{secondCond});
        
        %increment pairInd
        pairInd = pairInd + 1;
    end
end

%create figure 
figure;
axH = axes;
hold(axH,'on');

%create bar chart 
barH = barwitherr(semGamma, meanGamma);
barH.error.LineWidth = 2;

%add statistics 
criteria = [0.05 1e-2 1e-3];
% criteria = criteria/sqrt(length(pairPVal)); %bonferonni correct
sigstar(num2cell(statsPairs,2),pairPVal,[],[],criteria);

%set prober tick labels 
strLabels = convertTableToLegendString(uniqueConds);
axH.XTick = 1:length(strLabels);
axH.XTickLabel = strLabels;
axH.XTickLabelRotation = -45;

%label axes 
axH.YLabel.String = 'Distance to Hyperplane';

end
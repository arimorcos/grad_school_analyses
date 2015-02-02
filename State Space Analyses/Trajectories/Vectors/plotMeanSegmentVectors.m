function plotMeanSegmentVectors(segVectors,whichFactors,colorBy,toExclude)
%plotMeanSegmentVectors.m Plots mean segment vectors for each unique
%condition
%
%INPUTS
%segVectors - table output by getSegVectors
%whichFactors - which factors to plot
%colorBy - names of variables to color according to 
%toExclude - variables to exclude in filtering
%
%ASM 1/15

%condition check
%check that segVectors is a table
assert(istable(segVectors),'segVectors must be a table');

if nargin < 4
    toExclude = [];
else
    assert(ischar(toExclude) || iscell(toExclude),'Must provide toExclude as a cell or a string');
    if ~iscell(toExclude)
        toExclude = {toExclude};
    end
end

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

%process colorBy
if nargin < 3
    colorBy = segVectors.Properties.VariableNames;
else
    assert(ischar(colorBy) || iscell(colorBy),'Must provide colorBy as a cell or a string');
    if ~iscell(colorBy)
        colorBy = {colorBy};
    end
end

%get nTrials
nTrials = size(segVectors,1);

%find unique conditions
uniqueConds = unique(segVectors,'rows');
nConds = size(uniqueConds,1);

%get remaining variable names
varNames = segVectors.Properties.VariableNames;

%loop through each condition and generate mean vectors
meanVectors = nan(length(whichFactors),nConds);
stdVectors = nan(length(whichFactors),nConds);
for condInd = 1:nConds
    
    %find matching indices
    indMatch = true(nTrials,1); %assume all true
    for var = varNames
        indMatch(segVectors.(var{1}) ~= uniqueConds{condInd,var{1}}) = false; %remove if doesn't match condition
    end
    
    %extract vectors
    tempVectors = cat(2,vectors{indMatch});
    
    %get mean vector 
    meanVectors(:,condInd) = nanmean(tempVectors(whichFactors,:),2);
    
    %get std vector 
    stdVectors(:,condInd) = nanstd(tempVectors(whichFactors,:),0,2);
    
end

%generate unique color conditions 
if all(ismember(varNames,colorBy))
    colorConds = uniqueConds;
else
    colorVectors = segVectors(:,colorBy);
    colorConds = unique(colorVectors,'rows');
end
nColorConds = size(colorConds,1);

%create figure 
figH = figure;
axH = axes;
hold(axH,'on');

%get colors
colorsToPlot = distinguishable_colors(nColorConds);

%loop through and plot each vector 
plotH = gobjects(nConds,1);
legObj = gobjects(nColorConds,1);
seenColor = false(nColorConds,1);
for condInd = 1:nConds
    
    %plot 
    plotH(condInd) = plot3([0 meanVectors(1,condInd)], [0 meanVectors(2,condInd)],...
        [0 meanVectors(3,condInd)]);
    
    %find matching color 
    colorInd = ismember(colorConds,uniqueConds(condInd,colorBy),'rows');
    
    %set line color
    plotH(condInd).Color = colorsToPlot(colorInd,:);
    
    %store for legend
    if ~seenColor(colorInd)
        legObj(colorInd) = plotH(condInd);
        seenColor(colorInd) = true;
    end
    
    %set button down function
    plotH(condInd).ButtonDownFcn = {@clickButtonFunc,meanVectors(:,condInd),...
        stdVectors(:,condInd),uniqueConds(condInd,:)};
    
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

%add legend
legStrings = convertTableToLegendString(colorConds);
legend(legObj, legStrings{:});

end

function clickButtonFunc(src,evnt,meanVector,stdVector,dispCond)

if evnt.Button == 1
    disp(dispCond);
elseif evnt.Button == 3
    if isempty(src.UserData)
        %generate ellipsoid
        [ellX,ellY,ellZ] = ellipsoid(meanVector(1),meanVector(2),...
            meanVector(3),stdVector(1),stdVector(2),...
            stdVector(3));
        surfH = surf(ellX,ellY,ellZ);
        surfH.FaceAlpha = 0.5;
        src.UserData = surfH;
    elseif ishandle(src.UserData)
        delete(src.UserData);
        src.UserData = [];
    end
end
end

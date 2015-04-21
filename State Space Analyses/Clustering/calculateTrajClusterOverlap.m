function overlapIndex = calculateTrajClusterOverlap(dataCell,clusterIDs,varargin)
%calculateClusterOverlap.m Calculates the overlap in active neurons between
%clusters using the threshold specified
%
%INPUTS
%dataCell - dataCell containing imaging data
%clusterIDs - clusterIDs output by getClusteredMarkovMatrix
%
%OPTIONAL INPUTS
%zThresh - threshold as standard deviations above mean to count as active 
%
%OUTPUTS
%overlapIndex - nClusteredTraj x nClusteredTraj array of overlap indices
%
%ASM 4/15

%% handle inputs
zThresh = 1;
%process varargin
if nargin > 1 || ~isempty(varargin)
    if isodd(length(varargin))
        error('Must provide a name and value for each argument');
    end
    for argInd = 1:2:length(varargin) %for each argument
        switch lower(varargin{argInd})
            case 'zthresh'
                zThresh = varargin{argInd+1};
        end
    end
end

%% get clustered traces
clustTraces = getClusteredNeuronalActivity(dataCell,clusterIDs,[],'sortBy',...
    'none');
nPoints = length(clustTraces);
nUnique = cellfun(@(x) size(x,2),clustTraces);
nNeurons = size(clustTraces{1},1);

%% cluster trajectories
clusterTraj = clusterClusteredTrajectories(clusterIDs);
uniqueTraj = unique(clusterTraj);
nUniqueTraj = length(uniqueTraj);


%% bin as active or inactive 
actNeurons = cell(size(clustTraces));
for point = 1:nPoints
    actNeurons{point} = clustTraces{point} >= zThresh;
end


%% get all active neurons for each trajectory
actNeuronsTraj = cell(nUniqueTraj,1);
for trajInd = 1:nUniqueTraj
    %get mode trajectory 
    modeTraj = mode(clusterIDs(clusterTraj == uniqueTraj(trajInd),:));
    
    for point = 1:nPoints
        actNeuronsTraj{trajInd} = cat(1,actNeuronsTraj{trajInd},...
            find(actNeurons{point}(:,modeTraj(point)==unique(clusterIDs(:,point)))));
    end
end

%% calculate overlapIndex 

overlapIndex = ones(nUniqueTraj);
for startTraj = 1:nUniqueTraj
    for endTraj = startTraj+1:nUniqueTraj
        overlap = length(intersect(actNeuronsTraj{startTraj},...
            actNeuronsTraj{endTraj}))/length(union(actNeuronsTraj{startTraj},...
            actNeuronsTraj{endTraj}));
        overlapIndex(startTraj,endTraj) = overlap;
        overlapIndex(endTraj,startTraj) = overlap;     
    end
end

%% plot 
figH = figure;
axH = axes;
imagescnan(1:nUniqueTraj,1:nUniqueTraj,overlapIndex,[0 1]);
axH.XTick = 1:nUniqueTraj;
axH.YTick = 1:nUniqueTraj;
axH.FontSize = 20;
axH.XLabel.String = 'Clustered trajectory index';
axH.YLabel.String = 'Clustered trajectory index';
axH.XLabel.FontSize = 30;
axH.YLabel.FontSize = 30;

%add colorbar 
cBar = colorbar;
cBar.FontSize = 20;
cBar.Label.String = 'Overlap Index';
cBar.Label.FontSize = 30;

%add title 
axH.Title.String = sprintf('Clustered trajectory overlap, zThresh: %.1f',zThresh);
    
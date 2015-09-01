function [mMat,cMat,clusterIDs,clusterCenters] = getClusteredMarkovMatrix(dataCell,varargin)
%getClusteredMarkovMatrix.m Creates a markov transition matrix from
%clustered states for several points within the maze
%
%INPUTS
%dataCell - dataCell containing imaging data
%
%OUTPUTS
%mMat - nPoints-1 x 1 cell array of nClustersPointN x
%   nClustersPointN+1 matrix of transition probabilities
%cMat - structure containing cluster labels for different properties
%clusterIDs - nTrials x nPoints array of cluster IDs
%clusterCenters - nPoints x 1 cell array each containing a nNeurons x
%   nClusters array of clusterCenters
%
%ASM 4/15

nPoints = 10;
clusterType = 'ap';
shuffleIDs = false;
useBehavior = false;
oneClustering = false;
perc = 10;
whichNeurons = [];
traceType = 'dFF';
range = [0.5 0.75];

%process varargin
if nargin > 1 || ~isempty(varargin)
    if isodd(length(varargin))
        error('Must provide a name and value for each argument');
    end
    for argInd = 1:2:length(varargin) %for each argument
        switch lower(varargin{argInd})
            case 'clustertype'
                clusterType = varargin{argInd+1};
            case 'shuffleids'
                shuffleIDs = varargin{argInd+1};
            case 'usebehavior'
                useBehavior = varargin{argInd+1};
            case 'oneclustering'
                oneClustering = varargin{argInd+1};
            case 'perc'
                perc = varargin{argInd+1};
            case 'whichneurons'
                whichNeurons = varargin{argInd+1};
            case 'tracetype'
                traceType = varargin{argInd+1};    
            case 'range'
                range = varargin{argInd+1};
                
        end
    end
end

%get yPosBins
yPosBins = dataCell{1}.imaging.yPosBins;

if useBehavior
    traces = catBinnedDataFrames(dataCell);
    keepVar = 2:6; %2 - xPos, 3 - yPos, 4 - view angle, 5 - xVel, 6 - yVel
    traces = traces(keepVar,:,:);
else
    switch lower(traceType)
        case 'dff'
            %get traces
            [~,traces] = catBinnedTraces(dataCell);
        case 'deconv'
            traces = catBinnedDeconvTraces(dataCell);
        otherwise 
            error('Can''t interpret trace type');
    end
end

if ~isempty(whichNeurons)
    traces = traces(whichNeurons,:,:);
end

%get nNeurons
nTrials = size(traces,3);

%%%%%%%%% Create matrix of values at each point in the maze

tracePoints = getMazePoints(traces,yPosBins,range);

%%%%%%%%%%%% cluster
if oneClustering
    reshapePoints = reshape(tracePoints,size(tracePoints,1),...
        size(tracePoints,2)*size(tracePoints,3));
    allClusterIDs = apClusterNeuronalStates(reshapePoints, perc);
    clusterIDs = reshape(allClusterIDs,size(tracePoints,3),size(tracePoints,2));
else
    clusterIDs = nan(nTrials,nPoints);
    for point = 1:nPoints
        switch lower(clusterType)
            case 'ap'
                clusterIDs(:,point) = apClusterNeuronalStates(squeeze(tracePoints(:,point,:)), perc);
            case 'dbscan'
                clusterIDs(:,point) = dbscanClusterNeuronalStates(squeeze(tracePoints(:,point,:)));
            otherwise
                error('Cannot interpret cluster type: %s',clusterType);
        end
        
        if shuffleIDs
            clusterIDs(:,point) = shuffleArray(clusterIDs(:,point));
        end
    end
end

%get colors for matrix
if oneClustering
    cMat = getClusterCMatOneClustering(clusterIDs,dataCell);
else
    cMat = getClusterCMat(clusterIDs,dataCell);
end


%get transition matrix
mMat = createTransitionMatrix(clusterIDs);

%get cluster centers
clusterCenters = getClusterCenters(clusterIDs,tracePoints);

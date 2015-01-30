function trajSep = calcTrajSeparation(dataCell,conditions,varargin)
%calcTrajSeparation.m Calculates the separation between trajectories
%contained in conditions at every bin. 
%
%INPUTS
%dataCell - dataCell containing imaging data
%conditions - cell rray of condition strings
%
%OPTIONAL INPUTS
%whichFactors - which factors to calculate distance based upon 
%whichFactorSet - which factor set to use
%
%OUTPUTS
%trajSep - nPairs x nBins array of separations
%
%ASM 1/15

%check inputs
assert(iscell(conditions),'Conditions must be a cell array');
assert(all(getCellVals(dataCell,'imaging.imData')),'dataCell must contain only imaging data');
assert(isfield(dataCell{1}.imaging,'binnedDFFTraces'),'Imaging data must be binned');

%process varargin
whichFactorSet = 1;
whichFactors = 1:5;
distType = 'euclidean';

if nargin > 1 || ~isempty(varargin)
    if isodd(length(varargin))
        error('Must provide a name and value for each argument');
    end
    for argInd = 1:2:length(varargin) %for each argument
        switch lower(varargin{argInd})
            case 'whichfactorset'
                whichFactorSet = varargin{argInd+1};
            case 'whichfactors'
                whichFactors = varargin{argInd+1};
            case 'disttype'
                distType = varargin{argInd+1};                
        end
    end
end

%get nConds
nConds = length(conditions);

%subset into conditions 
condSub = cell(nConds,1);
for condInd = 1:nConds
    condSub{condInd} = getTrials(dataCell,conditions{condInd});
end

%get binned trajectories for each 
trajBinned = cell(nConds,1);
for condInd = 1:nConds
    trajBinned{condInd} = catBinnedFactors(condSub{condInd},whichFactorSet);
    trajBinned{condInd} = trajBinned{condInd}(whichFactors,:,:);
end

%get nPairs
nPairs = sum(sum(triu(ones(length(condSub{1}),length(condSub{2})))));

%get nBins 
nBins = size(trajBinned{1},2);

%calculate pairwise distance at each bin 
trajSep = nan(nPairs,nBins);
for binInd = 1:nBins
    tempDist = pdist2(squeeze(trajBinned{1}(:,binInd,:))',...
        squeeze(trajBinned{2}(:,binInd,:))',distType);
    trajSep(:,binInd) = tempDist(logical(triu(ones(size(tempDist)))));
end


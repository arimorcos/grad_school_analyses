function dataCell = factorAnalysisDataCell(dataCell,varargin)
%factorAnalysisDataCell.m Performs factor analysis on dataCell and copies
%into each field of dataCell
%
%INPUTS
%dataCell - dataCell containing imaging data
%
%VARARGIN
%nFactors - 1 x nFactorSet array of nFactors to store. Default is [3 10].
%zScore - should zScore or not. Default is false.
%maxIter - max iterations for rotatefactors. Default is 10000.
%
%OUTPUTS
%dataCell - dataCell containing factor analyzed data
%
%ASM 9/14

nFactors = [3 10 15];
shouldZScore = false;
maxIter = 10000;
shouldSmooth = true;
smoothWin = 60;
skipInd = [];

%process varargin
if nargin > 1 || ~isempty(varargin)
    if isodd(length(varargin))
        error('Must provide a name and value for each argument');
    end
    for argInd = 1:2:length(varargin) %for each argument
        switch lower(varargin{argInd})
            case 'nfactors'
                nFactors = varargin{argInd+1};
            case 'zscore'
                shouldZScore = varargin{argInd+1};
            case 'maxiter'
                maxIter = varargin{argInd+1};
            case 'shouldsmooth'
                shouldSmooth = varargin{argInd+1};
            case 'smoothwin'
                smoothWin = varargin{argInd+1};
            case 'skipind'
                skipInd = varargin{argInd+1};
        end
    end
end

%get traces
dFFTraces = dataCell{1}.imaging.completeDFFTrace;
% dGRTraces = dataCell{1}.imaging.completeDGRTrace;

%smooth
if shouldSmooth
    for cellInd = 1:size(dFFTraces,1)
        dFFTraces(cellInd,:) = smooth(dFFTraces(cellInd,:),smoothWin);
%         dGRTraces(cellInd,:) = smooth(dGRTraces(cellInd,:),smoothWin);
    end
end
%zScore
if shouldZScore
    dFFTraces = zScoreTraces(dFFTraces);
%     dGRTraces = zScoreTraces(dGRTraces);
end

%get nFactorSets
nFactorSets = length(nFactors);

%initialize projTraces
projDFF = cell(1,nFactorSets);
% projDGR = cell(1,nFactorSets);

%loop through each factor set and calculate factors 
for factorInd = 1:nFactorSets
    
    %skip certain factors
    if ismember(factorInd,skipInd)
        continue;
    end
    
    %perform for dFFTraces
    [lambda,psi,T,stats,F] = factoran(dFFTraces',nFactors(factorInd),...
        'maxit',maxIter);
    
    %project traces
    projDFF{factorInd} = (dFFTraces'*lambda)';
    
    %store info
    dataCell{1}.imaging.factorAn{factorInd}.dFF.nFactors = nFactors(factorInd);
    dataCell{1}.imaging.factorAn{factorInd}.dFF.lambda = lambda;
    dataCell{1}.imaging.factorAn{factorInd}.dFF.psi = psi;
    dataCell{1}.imaging.factorAn{factorInd}.dFF.T = T;
    dataCell{1}.imaging.factorAn{factorInd}.dFF.stats = stats;
    dataCell{1}.imaging.factorAn{factorInd}.dFF.F = F;
    
    %perform for dGRTraces
%     [lambda,psi,T,stats,F] = factoran(dGRTraces',nFactors(factorInd),...
%         'maxit',maxIter);
%     
%     %project traces
%     projDGR{factorInd} = (dGRTraces'*lambda)';
%     
%     %store info
%     dataCell{1}.imaging.factorAn{factorInd}.dGR.nFactors = nFactors(factorInd);
%     dataCell{1}.imaging.factorAn{factorInd}.dGR.lambda = lambda;
%     dataCell{1}.imaging.factorAn{factorInd}.dGR.psi = psi;
%     dataCell{1}.imaging.factorAn{factorInd}.dGR.T = T;
%     dataCell{1}.imaging.factorAn{factorInd}.dGR.stats = stats;
%     dataCell{1}.imaging.factorAn{factorInd}.dGR.F = F;
    
end

%get trialIDs
trialIDs = dataCell{1}.imaging.trialIDs;

%get number of unique, complete trials
uniqueTrials = unique(trialIDs(1,logical(trialIDs(2,:))));
nUniqueTrials = length(uniqueTrials);

%cycle through each unique trial
for trialInd = 1:nUniqueTrials
    
    
    %get frameInd corresponding to trial
    frameInd = trialIDs(1,:) == uniqueTrials(trialInd);
    
    %loop through each factor set
    for factorInd = 1:nFactorSets
        
        %skip certain factors
        if ismember(factorInd,skipInd)
            continue;
        end
        
        %store projDFF and projDGR subset in dataCell
        dataCell{uniqueTrials(trialInd)}.imaging.projDFF{factorInd} = projDFF{factorInd}(:,frameInd);
%         dataCell{uniqueTrials(trialInd)}.imaging.projDGR{factorInd} = projDGR{factorInd}(:,frameInd);
    end
    
end




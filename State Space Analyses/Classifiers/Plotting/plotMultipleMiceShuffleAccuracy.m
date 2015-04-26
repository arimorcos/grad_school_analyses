function handles = plotMultipleMiceShuffleAccuracy(trace,shuffleTrace,xVals,plotType,maxValue)
%plotMultipleMiceShuffleAccuracy.m Plots multiple mouse accuracy on single
%plot
%
%INPUTS
%trace - nMice x 1 cell array of traces
%shuffleTrace - nMice x 1 cell array of shuffle traces
%xVals - nMice x 1 cell array of x values
%plotType - options: 'zScore','dashBounds'
%
%OUTPUTS
%handles - handle structure
%
%ASM 4/15

if nargin < 5 || isempty(maxValue)
    maxValue = false;
end

if nargin < 4 || isempty(plotType)
    plotType = 'zScore';
end

%get nMice
nMice = length(trace);



%loop through and plot
handles = [];
for mouseInd = 1:nMice
    
    %take max value
    if maxValue
        [~,maxInd] = max(trace{mouseInd});
        trace{mouseInd} = trace{mouseInd}(maxInd);
        shuffleTrace{mouseInd} = shuffleTrace{mouseInd}(:,maxInd);
        xVals{mouseInd} = xVals{mouseInd}(maxInd);
    end
    
    switch plotType
        case 'zScore'
            handles = plotAsZScoreShuffle(trace{mouseInd},shuffleTrace{mouseInd},xVals{mouseInd},handles);
        case 'dashBounds'
            handles = plotWithDashedShuffle(trace{mouseInd},shuffleTrace{mouseInd},xVals{mouseInd},handles);
        otherwise
            error('Cannot interpret %s',plotType);
    end
end

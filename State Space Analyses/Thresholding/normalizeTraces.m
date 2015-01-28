function normTraces = normalizeTraces(traces,normInd,allData,usedSortOrder)
%normalizeTraces.m Normalized traces individually or as a set
%
%INPUTS
%traces - 1 x nTraces cell array of traces or single trace
%normInd - should normalize each trace individually
%allData - unsorted traces
%usedSortOrder - if normalized combined, sort order for each trace
%
%OUTPUTS
%normTraces - 1 x nTraces cell array of normalized traces
%
%ASM 1/14

%convert to cell if necessary
if ~iscell(traces)
    traces = {traces};
end

%get max 
normMax = max(allData,[],2);

%initialize normTraces
normTraces = cell(size(traces));

%loop through each trace and normalize
for i = 1:length(traces)

    %if normInd, update normMax
    if normInd 
        currNormMax = max(traces{i},[],2);
    else
        currNormMax = normMax(usedSortOrder{i},:);
    end
    
    %divide each neuron by normMax
    normTraces{i} = traces{i}./repmat(currNormMax,1,size(traces{i},2));
    
end
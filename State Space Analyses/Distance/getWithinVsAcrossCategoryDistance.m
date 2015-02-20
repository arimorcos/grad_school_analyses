function [segIntraDist,segInterDist] = getWithinVsAcrossCategoryDistance(dataCell,netEvDist)
%getWithinVsAcrossCategoryDistance.m Calculates pairwise distances at each
%segment for a given net evidence distance with the same category vs
%different categories
%
%INPUTS
%dataCell - dataCell containing imaging data
%netEvDist - distance in net evidence space to use 
%
%OUTPUTS
%segIntraDist - 1 x nSeg cell array fo distances within a category 
%segInterDist - 1 x nSeg cell array of distances across categories
%
%ASM 2/15

%seg ranges
segRanges = 0:80:480;

%get net evidence
netEvidence = getNetEvidence(dataCell);
nSeg = size(netEvidence,2);

%get unique net evidence at each segment 
uniqueSegNetEv = arrayfun(@(x) unique(netEvidence(:,x)),1:nSeg,...
    'UniformOutput',false);

%initialize
segInterDist = cell(1,nSeg);
segIntraDist = cell(1,nSeg);

%loop through each segment 
for segInd = 1:nSeg
   
    %find out if test is possible 
    %get pairwise net evidence distances which match requested distance
    netEvDistances = find(tril(abs(bsxfun(@minus,abs(uniqueSegNetEv{segInd}),...
        abs(uniqueSegNetEv{segInd})'))) == netEvDist);
    
    if isempty(netEvDistances)
        continue;
    end
    
    %convert to indices 
    [row, col] = ind2sub([length(uniqueSegNetEv{segInd}) length(uniqueSegNetEv{segInd})],...
        netEvDistances);
    
    %convert to net evidence conditions 
    netEvCompare = [uniqueSegNetEv{segInd}(row), uniqueSegNetEv{segInd}(col)];
    
    %remove rows with 0
    netEvCompare = netEvCompare(all(netEvCompare,2),:);
    if isempty(netEvCompare)
        continue;
    end
    
    %check if same sign 
    sameCategory = sign(netEvCompare(:,1)) == sign(netEvCompare(:,2));
    
    %loop through each condition and get data
    for category = 1:length(sameCategory)
        
        %generate conditiosn 
        conditions = {sprintf('netEv==%d,%d',segInd,netEvCompare(category,1)),...
            sprintf('netEv==%d,%d',segInd,netEvCompare(category,2))};
        
        %get distances
        distData = calcStateSpaceDistance(dataCell,conditions,true);
        
        %subset to segment 
        tempDistAll = distData.interDistances;
        indToKeep = distData.yPosBins > segRanges(segInd) & distData.yPosBins <= segRanges(segInd+1);
        distSeg = mean(tempDistAll(indToKeep,:))';
        
        %concatenate to appropriate field 
        if sameCategory(category)
            segIntraDist{segInd} = cat(1,segIntraDist{segInd},distSeg);
        else
            segInterDist{segInd} = cat(1,segInterDist{segInd},distSeg);
        end
    end 
    
end
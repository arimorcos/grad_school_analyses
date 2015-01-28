function [netEvSameSegDist,segIDSameSegDist] = calcSameSegInfo(nSeg,nSegIds,...
    segIdConds,netEvConds,nNetEvConds,dist,segId,netEv,segNum)

%initialize arrays
netEvSameSegDist = cell(nNetEvConds,nNetEvConds,nSeg);
segIDSameSegDist = cell(nSegIds,nSegIds,nSeg);

%loop through each segment and extract proper distances
for segInd = 1:nSeg %for each segment number
    
    %find indices which match segment
    segTrialInds = segNum == segInd;
    
    %get subset of distance matrix for same segment
    distSub = dist(segTrialInds,segTrialInds);
    
    %get subset of segId and netEv which match same segment
    segIdSub = segId(segTrialInds);
    netEvSub = netEv(segTrialInds);
    
    %loop through each net evidence condition and find combinations
    for evCondRow = 1:nNetEvConds %for each net evidence row
        
        %find trials which match evCondRow
        rowTrials = find(netEvSub == netEvConds(evCondRow));
        
        for evCondColumn = 1:evCondRow %for each net evidence column up to the current row
            
            %find trials which match evCondRow
            columnTrials = find(netEvSub == netEvConds(evCondColumn));
            
            %check for empty inputs
            if isempty(rowTrials) || isempty(columnTrials)
                continue;
            end
            
            %get all combinations of row and column
            allCombTrials = allcomb(rowTrials,columnTrials);
            allCombTrials = cat(1,allCombTrials,allcomb(columnTrials,rowTrials));%add on flipped row and column
            
            %get linear indices which match row and column combinations
            trialIndices = sub2ind(size(distSub),allCombTrials(:,1),allCombTrials(:,2));
            
            %only take unique trialIndices
            trialIndices = unique(trialIndices);
            
            %store distance values 
            netEvSameSegDist{evCondRow,evCondColumn,segInd} = distSub(trialIndices);
        end
    end
    
    %loop through segment ID conditiosn 
    for segIDRow = 1:nSegIds %for each segID row
        
        %find trials which match segIDRow
        rowTrials = find(segIdSub == segIdConds(segIDRow));
        
        for segIDColumn = 1:segIDRow %for each segID column
            
            %find trials which match segID
            columnTrials = find(segIdSub == segIdConds(segIDColumn));
            
            %check for empty inputs
            if isempty(rowTrials) || isempty(columnTrials)
                continue;
            end
            
            %get all combinations of row and column
            allCombTrials = allcomb(rowTrials,columnTrials);
            allCombTrials = cat(1,allCombTrials,allcomb(columnTrials,rowTrials));%add on flipped row and column
            
            %get linear indices which match row and column combinations
            trialIndices = sub2ind(size(distSub),allCombTrials(:,1),allCombTrials(:,2));
            
            %only take unique trialIndices
            trialIndices = unique(trialIndices);
            
            %store distance values 
            segIDSameSegDist{segIDRow,segIDColumn,segInd} = distSub(trialIndices);
        end
    end
    
end
end
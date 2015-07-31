function dataCell = filterROIGroups(dataCell,groups)
%filterROIGroups.m Only gets dFF traces corresponding to specific roi
%groups 
%
%INPUTS
%dataCell - dataCell containing imaging data
%groups - groups to keep
%
%OUTPUTS
%dataCell - dataCell containing imaging data filtered
%
%ASM 12/14

%get nTrials
nTrials = length(dataCell);

%loop through each trial
for trialInd = 1:nTrials
    
    if ~dataCell{trialInd}.imaging.imData %skip if no imaging data
        continue;
    end
    
    %get nPlanes
    nPlanes = length(dataCell{trialInd}.imaging.dataFrames);
    
    for planeInd = 1:nPlanes
        
        %get roiGroups
        roiGroups = dataCell{trialInd}.imaging.roiGroups{planeInd};
        shouldKeep = ismember(roiGroups,groups);
        
        %copy everything to allData field
        if ~isfield(dataCell{trialInd}.imaging,'allROIDFFTraces') || ...
                isempty(dataCell{trialInd}.imaging.allROIDFFTraces{planeInd})
            dataCell{trialInd}.imaging.allROIDFFTraces{planeInd} = ...
                dataCell{trialInd}.imaging.dFFTraces{planeInd};
            
            if isfield(dataCell{trialInd}.imaging,'binnedDFFTraces')
                
                dataCell{trialInd}.imaging.allROIBinnedDFFTraces{planeInd} = ...
                    dataCell{trialInd}.imaging.binnedDFFTraces{planeInd};
                
                dataCell{trialInd}.imaging.allROIBinnedDeconvTraces{planeInd} = ...
                    dataCell{trialInd}.imaging.binnedDeconvTrace{planeInd};
            end
        end
        
        if ~isfield(dataCell{trialInd}.imaging,'allROIDeconvTraces') || ...
                isempty(dataCell{trialInd}.imaging.allROIDeconvTraces{planeInd})
            
            dataCell{trialInd}.imaging.allROIDeconvTraces{planeInd} = ...
                dataCell{trialInd}.imaging.deconvTrace{planeInd};

            if isfield(dataCell{trialInd}.imaging,'binnedDeconvTrace')
                
                dataCell{trialInd}.imaging.allROIBinnedDeconvTraces{planeInd} = ...
                    dataCell{trialInd}.imaging.binnedDeconvTrace{planeInd};
            end
            
        end
        
        %subset
        dataCell{trialInd}.imaging.dFFTraces{planeInd} = ...
            dataCell{trialInd}.imaging.allROIDFFTraces{planeInd}(shouldKeep,:);
        
        dataCell{trialInd}.imaging.deconvTrace{planeInd} = ...
            dataCell{trialInd}.imaging.allROIDeconvTraces{planeInd}(shouldKeep,:);
        
        if isfield(dataCell{trialInd}.imaging,'binnedDFFTraces')
            
            dataCell{trialInd}.imaging.binnedDFFTraces{planeInd} = ...
                dataCell{trialInd}.imaging.allROIBinnedDFFTraces{planeInd}(shouldKeep,:);

            dataCell{trialInd}.imaging.binnedDeconvTrace{planeInd} = ...
                dataCell{trialInd}.imaging.allROIBinnedDeconvTraces{planeInd}(shouldKeep,:);
            
        end
        
    end
    
end
        
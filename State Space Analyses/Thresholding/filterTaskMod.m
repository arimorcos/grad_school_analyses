function [taskModCells,taskModTraces,nonTraces] = filterTaskMod(dFFTraces,modThresh1,modThresh2,minFrames)
%filterTaskMod.m Function to find task-modulated cells. Cells with periods
%of activity above modThresh*mean activity lasting at least nBins with mean
%activity >=modThresh2*mean(outside periods)
%
%INPUTS
%dFFTraces - nCells x nFramesarray
%modThresh1 - first filter (should be relative to 1, so 1.25 filters for
%   periods with activity 25% higher than the mean)
%modThresh2 - second filter 
%minFrames - minFrames
%
%OUTPUTS
%taskModCells - nCells x 1 logical of whether or not cells are task
%   modulated
%taskModTraces - nTaskModCells x nFrame
%nonTraces - nNonTaskModCells x nFrames
%
%ASM 2/14

if nargin < 4 || isempty(minFrames)
    minFrames = 7;
end
if nargin < 3 || isempty(modThresh2)
    modThresh2 = 3;
end
if nargin < 2 || isempty(modThresh1)
    modThresh1 = 1.25;
end

%get mean overall 
meanOverall = mean(dFFTraces,2);
modMeanThresh1 = meanOverall*modThresh1;

%find periods greater than modMeanThresh1
activePeriods = zeros(size(dFFTraces));
activeMeans = cell(1,size(dFFTraces,1));
regions = zeros(size(dFFTraces));
for i = 1:size(dFFTraces,1)
    activePeriods(i,:) = dFFTraces(i,:) >= modMeanThresh1(i);
    
    %ensure active periods last longer than minFrames
    regions(i,:) = bwlabel(activePeriods(i,:));
    
    %get area
    regProps = regionprops(regions(i,:),'Area');
    regAreas = cat(2,regProps.Area);
    
    %find values below thresh
    floorInds = find(regAreas < minFrames);
    
    %floor values of one
    activePeriods(i,ismember(regions(i,:),floorInds)) = 0;
    
    %get mean of each active period
    activeMeans{i} = zeros(1,length(regAreas));
    for j = 1:length(regAreas)
        activeMeans{i}(j) = mean(dFFTraces(i,regions(i,:)==j));
    end
    
end

%get inactive periods (all frames not active)
inactivePeriods = ~activePeriods;

%find mean across inactive periods
inactiveMean = zeros(size(dFFTraces,1),1);
for i = 1:size(dFFTraces,1)
    inactiveMean(i) = mean(dFFTraces(i,inactivePeriods(i,:)));
end
inactiveThresh = inactiveMean*modThresh2;

%ensure mean of each active period is greater than mean of inactive periods
for i = 1:size(dFFTraces,1) %for each cell
    %find which regions have mean higher than thresh
    discardRegions = find(activeMeans{i} < inactiveThresh(i));
    
    for j = 1:length(discardRegions) %for each discard region
        activePeriods(i,regions(i,:)==discardRegions(j)) = 0;
    end
end

%find cells with no active periods
totalAct = sum(activePeriods,2);
taskModCells = totalAct ~= 0;
inactiveCells = totalAct == 0;

%filter 
taskModTraces = dFFTraces(taskModCells,:,:);
nonTraces = dFFTraces(inactiveCells,:,:);



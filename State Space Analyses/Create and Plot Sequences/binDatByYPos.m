function [dataCell, posBins] = binDatByYPos(dataCell,binSize,range)
%binFramesByYPos.m function to bin dF/F according to mouse position. Takes
%into account both x position and y position (yPos + |xPos|) after 90% of
%maze length
%
%INPUTS
%dataCell - dataCell containing imaging data
%binSize - binSize in units
%range for bins
%
%OUTPUTS
%dataCell - dataCell with binned data stored in each trial
%binnedDFFTraces - nCells x nBins x nTrials array containing the binned
%   data
%yPosBins - 1 x nBins array containing the y positions corresponding to
%   each bin
%
%ASM 10/13
%Modified ASM 1/14 Added in xPos


if nargin < 3
    range = [];
end

%get nTrials
nTrials = length(dataCell);

%read dataFrames from all imaging trial to get min/max yPos
allData = getCellVals(dataCell,'dat');
yPosAll = allData(3,:);
xPosAll = allData(2,:);
maxYPos = round(max(yPosAll));
yThresh = 0.9*maxYPos;

%add abs(xPos) to yPos values above yThresh
xyData = yPosAll;
xyData(yPosAll >= yThresh) = xyData(yPosAll >= yThresh) + abs(xPosAll(yPosAll >= yThresh));
%     xyData = yPosAll + abs(xPosAll);
if isempty(range)
    minXY = floor(min(xyData));
    maxXY = ceil(max(xyData));
    binMin = minXY + binSize;
    binMax = maxXY - binSize;
else
    binMin = range(1);
    binMax = range(2);
end

%generate linear vector with binSize spacing between min and max
posBins = binMin:binSize:binMax;
nBins = length(posBins);

%initalize binnedDFFTraces
binnedDat= zeros(size(allData,1),nBins,nTrials);

%cylce through each trace and bin dF/F
for trialInd = 1:nTrials
    
    %get dFF, PCA and dataFrames
    tempDat = dataCell{trialInd}.dat;
    
    %sum |x| and y for y > yThresh
    xyFrames = tempDat(3,:);
    xFrames = tempDat(2,:);
    xyFrames(xyFrames >= yThresh) = xyFrames(xyFrames >= yThresh) + abs(xFrames(xyFrames >= yThresh));
    
    for binNum = 1:nBins %for each bin
        
        if binNum < nBins
            %get indices
            binInd = xyFrames >= posBins(binNum) & xyFrames < posBins(binNum+1);
        else
            binInd = xyFrames >= posBins(binNum);
        end
        
        %store mean of trial subset
        if any(binInd)
            binnedDat(:,binNum,trialInd) = nanmean(tempDat(:,binInd),2);
        end
        
    end
    
    %store in dataCell
    dataCell{trialInd}.yPosBins = posBins;
    dataCell{trialInd}.binnedDat = binnedDat(:,:,trialInd);
end
    
    
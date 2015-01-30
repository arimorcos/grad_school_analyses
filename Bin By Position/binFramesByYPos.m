function [dataCell, binnedDGRTraces, posBins] = binFramesByYPos(dataCell,binSize,range,shouldInterp)
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

if nargin < 4
    shouldInterp = true;
end

if nargin < 3
    range = [];
end

%get imaging subset
imSub = getTrials(dataCell,'imaging.imData == 1');
imTrials = findTrials(dataCell,'imaging.imData == 1');
imTrials = find(imTrials == 1);

%get nTrials
nTrials = length(imSub);

%determine if multiple planes
nPlanes = length(imSub{1}.imaging.dataFrames);

%read dataFrames from all imaging trial to get min/max yPos
allDataFrames = [];
for planeInd = 1:nPlanes
    allDataFrames = cat(2,allDataFrames,getCellVals(imSub,sprintf('imaging.dataFrames{%d}',planeInd)));
end
yPosAll = allDataFrames(3,:);
xPosAll = allDataFrames(2,:);
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

%find out if contains factor data
if isfield(imSub{1}.imaging,'projDFF')
    binFact = true;
else
    binFact = false;
end


%generate linear vector with binSize spacing between min and max
posBins = binMin:binSize:binMax;
nBins = length(posBins);

for planeInd = 1:nPlanes
    
    if isempty(imSub{1}.imaging.dataFrames{planeInd})
        continue;
    end
    
    %get nCells
    nCells = size(imSub{1}.imaging.dFFTraces{planeInd},1);
    %     nPCs = size(imSub{1}.imaging.dGRPCA{planeInd},1);
    if binFact %get number of factors in each cell
        nFact = cellfun(@(x) size(x,1),imSub{1}.imaging.projDFF);
        nFactSets = length(nFact);
    end
    
    %initalize binnedDFFTraces
    %     binnedDGRTraces = zeros(nCells,nBins,nTrials);
    %     binnedPCATraces = zeros(nPCs,nBins,nTrials);
    binnedDFFTraces = nan(nCells,nBins,nTrials);
    binnedDataFrames = nan(size(imSub{1}.imaging.dataFrames{1},1),nBins,nTrials);
    if binFact
        binnedDFFFact = cell(1,nFactSets);
        %         binnedDGRFact = cell(1,nFactSets);
        for factInd = 1:nFactSets
            binnedDFFFact{factInd} = nan(nFact(factInd),nBins,nTrials);
            %             binnedDGRFact{factInd} = zeros(nFact(factInd),nBins,nTrials);
        end
    end
    
    
    %     nFramesAltered = 0;
    
    %cylce through each trace and bin dF/F
    for trialInd = 1:nTrials
        
        %get dFF, PCA and dataFrames
        %         tempDGR = imSub{trialInd}.imaging.dGRTraces{planeInd};
        tempDFF = imSub{trialInd}.imaging.dFFTraces{planeInd};
        %         tempPCA = imSub{trialInd}.imaging.dGRPCA{planeInd};
        if binFact
            tempFactDFF = cell(1,nFactSets);
            %         tempFactDGR = cell(1,nFactSets);
            for factInd = 1:nFactSets
                tempFactDFF{factInd} = imSub{trialInd}.imaging.projDFF{factInd};
                %             tempFactDGR{factInd} = imSub{trialInd}.imaging.projDGR{factInd};
            end
        end
        dataFrames = imSub{trialInd}.imaging.dataFrames{planeInd};
        
        %sum |x| and y for y > yThresh
        xyFrames = dataFrames(3,:);
        xFrames = dataFrames(2,:);
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
                %                 binnedDGRTraces(:,binNum,trialInd) = nanmean(tempDGR(:,binInd),2);
                %                 binnedPCATraces(:,binNum,trialInd) = nanmean(tempPCA(:,binInd),2);
                binnedDFFTraces(:,binNum,trialInd) = nanmean(tempDFF(:,binInd),2);
                binnedDataFrames(:,binNum,trialInd) = nanmean(dataFrames(:,binInd),2);
                if binFact
                    for factInd = 1:nFactSets
                        if ~isempty(tempFactDFF{factInd})
                            binnedDFFFact{factInd}(:,binNum,trialInd) = nanmean(tempFactDFF{factInd}(:,binInd),2);
                        end
                        %                     binnedDGRFact{factInd}(:,binNum,trialInd) = nanmean(tempFactDGR{factInd}(:,binInd),2);
                    end
                end
            end
            
        end
        
        %         nFramesAltered = nFramesAltered + sum(sum(binnedDGRTraces(:,:,j)==0));
        
        %perform interpolation
        if shouldInterp
            for neuronInd = 1:nCells
                %                 binnedDGRTraces(neuronInd,:,trialInd) = interpLowValTraces(binnedDGRTraces(neuronInd,:,trialInd),'0','pchip');
                %             binnedPCATraces(neuronInd,:,j) = interpLowValTraces(binnedPCATraces(neuronInd,:,j),'0','pchip');
                %                 binnedDFFTraces(neuronInd,:,trialInd) = interpLowValTraces(binnedDFFTraces(neuronInd,:,trialInd),.1,'pchip');
                binnedDFFTraces(neuronInd,:,trialInd) = interpNanTraces(binnedDFFTraces(neuronInd,:,trialInd),'linear');
            end
            for dataVar = 1:size(binnedDataFrames,1)
               binnedDataFrames(dataVar,:,trialInd) = interpNanTraces(...
                   binnedDataFrames(dataVar,:,trialInd),'linear');
            end
            if binFact
                for factInd = 1:nFactSets
                    for neuronInd = 1:size(binnedDFFFact{factInd},1)
                        binnedDFFFact{factInd}(neuronInd,:,trialInd) = ...
                            interpNanTraces(binnedDFFFact{factInd}(neuronInd,:,trialInd),'linear');
                    end
                end
            end
        end
        
        %store in dataCell
        dataCell{imTrials(trialInd)}.imaging.yPosBins = posBins;
        %         dataCell{imTrials(trialInd)}.imaging.binnedDGRTraces{planeInd} = binnedDGRTraces(:,:,trialInd);
        %         dataCell{imTrials(trialInd)}.imaging.binnedPCATraces{planeInd} = binnedPCATraces(:,:,trialInd);
        dataCell{imTrials(trialInd)}.imaging.binnedDFFTraces{planeInd} = binnedDFFTraces(:,:,trialInd);
        dataCell{imTrials(trialInd)}.imaging.binnedDataFrames = binnedDataFrames(:,:,trialInd);
        if binFact
            for factInd = 1:nFactSets
                dataCell{imTrials(trialInd)}.imaging.binnedFactDFF{planeInd}{factInd} = binnedDFFFact{factInd}(:,:,trialInd);
                %             dataCell{imTrials(trialInd)}.imaging.binnedFactDGR{planeInd}{factInd} = binnedDGRFact{factInd}(:,:,trialInd);
            end
        end
    end
end
% fprintf('nFramesAltered: %d',nFramesAltered);


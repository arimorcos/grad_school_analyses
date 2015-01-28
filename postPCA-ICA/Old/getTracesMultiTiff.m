function [dFFTraces,dGRTraces,meanF,meanR,baseline] = getTracesMultiTiff(folderPath,fileStr,...
    filtSeg,percentileVal,window,frameRate)
%getDFFTracesMultiTiff.m Extracts dFFTraces from multiple tiffs
%
%INPUTS
%folderPath - path to folder
%fileStr - filter string for green files
%filtSeg - m x n x nFilters array containing spatial filters
%percentileVal - percentile of average to set as baseline
%window - window in seconds around which to calculate baseline
%frameRate - frameRate of acquisition
%nFrames - total frames
%
%OUTPUTS
%dFFTraces - nFilters x nFrames array containing dF/F as percentage
%dGRTraces - nFilters x nFrames array containing dF/R as percentage
%meanF - nCells x nFrames array contianing mean green fluorescence
%meanR - nCells x nFrames array containing mean red fluorescence
%baseline - nCells x nFrames array containing baseline values
%
%ASM 5/14

%get files 
fileList = getMatchingFileList(folderPath,fileStr);
greenFiles = fileList(~cellfun(@isempty,regexp(fileList,'green')));
redFiles = fileList(~cellfun(@isempty,regexp(fileList,'red')));
nFiles = length(greenFiles);

%create waitbar
hWait = waitbar(0,'Getting traces');
setWaitbarLoc(hWait);

%initialize array
meanF = [];
meanR = [];

%calculate window in frames
winFrames = window*frameRate;

%loop through each file and extract traces
for fileInd = 1:nFiles
    
    %load tiff
    greenTiff = loadtiffAM(greenFiles{fileInd});
    redTiff = loadtiffAM(redFiles{fileInd});
    
    %extract trace
    meanF = cat(2,meanF,getRawTraces(greenTiff,filtSeg,-500));
    meanR = cat(2,meanR,getRawTraces(redTiff,filtSeg,-500));
    
    %update waitbar
    waitbar(fileInd/nFiles,hWait,sprintf('Extracting traces file %d/%d',fileInd,nFiles));
    
end

%set zero values to nan
% meanF(meanF < 20) = nan;
% meanR(meanR < 20) = nan;
interpThresh = 10;
for neuronInd = 1:size(meanF,1)    
    if any(meanF(neuronInd,:) < interpThresh)
        warning('Some mean green fluorescence values for cell %d are below %d...interpolating',neuronInd,interpThresh);
        meanF(neuronInd,:) = interpLowValTraces(meanF(neuronInd,:),interpThresh);
    end
    if any(meanR(neuronInd,:) < interpThresh)
        warning('Some mean red fluorescence values for cell %d are below %d...interpolating',neuronInd,interpThresh);
        meanR(neuronInd,:) = interpLowValTraces(meanR(neuronInd,:),interpThresh);
    end
    
    if any(isnan(meanF(neuronInd,:)))
        meanF(neuronInd,isnan(meanF(neuronInd,:))) = 0;
    end
    if any(isnan(meanR(neuronInd,:)))
        meanR(neuronInd,isnan(meanR(neuronInd,:))) = 0;
    end
end

%get baselines
baseline = getMovingPercentile(meanF,percentileVal,winFrames,hWait);

%calculate dFF
dFFTraces = 100*(meanF - baseline)./baseline;
dGRTraces = 100*(meanF - baseline)./meanR;

%close waitbar
close(hWait);
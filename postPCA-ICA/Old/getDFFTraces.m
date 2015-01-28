function [dFFTraces,meanF,baseline] = getDFFTraces(tiff,filtSeg,...
    percentileVal,window,frameRate)
%getDFFTraces.m Extracts deltaF/F traces from tiff based on spatial filters
%created by PCA/ICA
%
%INPUTS
%tiff - motion corrected tiff stack 
%filtSeg - m x n x nFilters array containing spatial filters
%percentileVal - percentile of average to set as baseline
%window - window in seconds around which to calculate baseline
%frameRate - frameRate of acquisition
%
%OUTPUTS
%dFFTraces - nFilters x nFrames array containing dF/F as percentage
%meanF - nCells x nFrames array contianing mean fluorescence
%baseline - nCells x nFrames array containing baseline values
%
%ASM 10/13

%create waitbar
hWait = waitbar(0,'Getting raw green traces');

meanF = getRawTraces(tiff,filtSeg,hWait);

%calculate window in frames
winFrames = window*frameRate;

%get baselines
baseline = getMovingPercentile(meanF,percentileVal,winFrames,hWait);

%calculate dFF
dFFTraces = 100*(meanF-baseline)./baseline;

%close waitbar
close(hWait);
end



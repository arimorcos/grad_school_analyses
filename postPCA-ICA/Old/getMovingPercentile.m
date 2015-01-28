function baseline = getMovingPercentile(meanF,percentileVal,winFrames,hWait)
%getMovingPercentile Gets moving percentile calculation
%
%INPUTS
%meanF - nCells x nFrames array of mean fluorescence values
%percentileVal - percentile to calculate for baseline
%winFrames - total size of window in frames
%
%OUTPUTS
%baseline - nCells x nFrames array of baseline values for each point
%
%ASM 10/13

if nargin < 4
    hWait = [];
end

%get nFrames
nFrames = size(meanF,2);

%break up winFrames
framesAhead = round(winFrames/2);
framesBehind = round(winFrames/2);

%initialize baseline
baseline = zeros(size(meanF));

%parpool
if isempty(gcp('nocreate'))
    parpool(8);
end

lastString = [];

%perform baseline calculation
for genInd = 1:1000:nFrames %for each frame
    
    %update waitbar
    if isempty(hWait)
        lastString = dispProgress('Processing frame %d/%d',genInd,genInd,nFrames,'lastString',lastString);
    else
        waitbar(genInd/nFrames,hWait,sprintf('Getting baseline... Frame %05d out of %05d',genInd,nFrames));
    end
    
    parfor i = genInd:genInd+1000
        %get data subset
        if i <= framesBehind %if first section of data
            dataSub = meanF(:, 1:i + framesAhead);
        elseif i > (nFrames - framesAhead) %if last section of data
            dataSub = meanF(:, i - framesBehind:end);
        else %if middle of data
            dataSub = meanF(:, i - framesBehind:i + framesAhead);
        end

        %calculate percentile
        dataSub = sort(dataSub,2);
        baseline(:,i) = dataSub(:,ceil(percentileVal*size(dataSub,2)/100));
    %         baseline(:,i) = prctile(dataSub,percentileVal,2);
    end
    
end

%remove last value
baseline = baseline(:,1:end-1);

dispProgress('Processing frame %d/%d',nFrames,nFrames,nFrames,'lastString',lastString);
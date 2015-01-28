function SNR = basicSNR(traces,winSize,frameRate,nSTD)
%basicSNR.m function which calculates SNR by taking a distribution of local
%values within a window and taking the left half of the peak to be a normal
%distribution (calculate STD based on that half), then reflecting the STD
%about the max and counting that as the noise level. Signal is the current
%frame value
%
%INPUTS
%traces - nCells x nFrames traces
%winSize - window size in seconds
%frameRate - frame rate in Hz
%nSTD - number of standard deviations 
%
%OUTPUTS
%SNR - nCells x nFrames array of SNR 
%
%ASM 3/14

%get nCells
nCells = size(traces,1);

%get nFrames
nFrames = size(traces,2);

%get window size
winFrames = round(winSize*frameRate);
if ~isodd(winFrames)
    winFrames = winFrames + 1; %make odd
end
halfWin = floor(winFrames/2); %get half point

%create start and stop indices
startIndices = [ones(1,halfWin) 1:(nFrames - halfWin)];
stopIndices = [(halfWin+1):nFrames nFrames*ones(1,halfWin)];

%initialize SNR
SNR = zeros(nCells,nFrames);

%create waitbar
hWait = waitbar(0,'Calculating signal/noise');

%loop through each cell and generate trace
for i = 1:nCells
    
    currTrace = traces(i,:);
    noise = arrayfun(@(startInd,stopInd) calculateNoise(currTrace(startInd:stopInd),nSTD),...
        startIndices,stopIndices);
    
    %calculate snr
    SNR(i,:) = currTrace./noise;   
    
    %update waitbar
    waitbar(i/nCells,hWait,sprintf('Calculating signal/noise...cell %d/%d',...
        i,nCells));
    
end

%delete waitbar
delete(hWait);




    

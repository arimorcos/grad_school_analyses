function [frameItRanges,frameIterations, itTimes,itVals,fRange] = ...
    alignVirmenSync(syncFilePath,vThresh)
%alignVirmenSync.m Gets virmen iteration numbers which correlate with
%each imaged frame
%
%INPUTS
%syncFilePath - path and name of sync file
%vThresh - threshold for change in voltage to pick up iteration start
%
%OUTPUTS
%frameItRanges - nFrames x 2 array containing start and stop iterations for each
%   frame
%frameIterations - 1 x nFrames cell of iterations corresponding to each
%   frame
%itTimes - 1 x nIterations array containing the indices of each iteration
%itVals - 1 x nIterations array containing the iteration numbers 
%fRange - nFrames x 2 array containing start and stop indices for each
%   frame
%
%
%ASM 12/14 based on alignVirmenPClamp

if nargin < 2 || isempty(vThresh)
    vThresh = 2;
end

startVThresh = vThresh;

%load in sync data
allData = load(syncFilePath);

%subset 
syncData = allData.data;

%check if multiple acquisitions
[nAcq, sepData] = separatePClampAcq(syncData);

%if multiple acquisitions, ask user which to select
if nAcq > 1
    figure;
    plot(syncData(2,1:10:end));
    options.WindowStyle = 'normal';
    whichAcq = inputdlg('Acquisition Number','Multiple Acquisitions Detected',...
        [1 100],{'1'},options);
    syncData = sepData{str2double(whichAcq)};
end

%break up into virmen and frame data
vData = syncData(1,:);
fData = syncData(2,:);

keepVirmen = true;
lastGreaterThan = false;
incSize = 0.1;
lastDiff = 0;
startTime = tic;
while keepVirmen
    
    %find all indices where vData increases from -5 to -1 or greater
    itTimes = find(diff(vData) >= vThresh)+1; %add one to compensate for diff

    %find first 10,000 iterations
    firstInd = find(vData > 0,1,'first');
    firstItVal = roundn(1e5*vData(firstInd),4);
    firstItInd = find(firstInd == itTimes);

    %initialize array of iteration numbers
    itVals = zeros(size(itTimes));

    %set firstItVal in correct place and populate rest of array with
    %iteration numbers
    itVals(firstItInd) = firstItVal;
    itVals(1:firstItInd - 1) = firstItVal - firstItInd + 1:firstItVal - 1; %everything up to val
    itVals(firstItInd + 1:end) = firstItVal + 1:firstItVal + length(itVals) - firstItInd; %everything after val

    %as sanity check, find last 10,000 iteration and ensure it lines up
    lastInd = find(vData > 0,1,'last');
    lastItVal = roundn(1e5*vData(lastInd),4);
    lastItInd = lastInd == itTimes;
    if itVals(lastItInd) ~= lastItVal
        %         warning('Iterations past first do not line up');
        if toc(startTime) > 20
            if abs(itVals(lastItInd) - lastItVal) < 3
                warning('Can''t converge on value for pclamp...taking value within 2');
                keepVirmen = false;
                continue;
            else
                error('Can''t converge on value for pclamp');
            end
        end
        keepVirmen = true;
        if (itVals(lastItInd) < lastItVal && (lastGreaterThan || vThresh == startVThresh)) ||...
                abs(lastDiff) > (abs(itVals(lastItInd) - lastItVal))
            vThresh = vThresh - incSize;
            incSize = 0.1*incSize;
        end
        if (itVals(lastItInd) > lastItVal)
            lastGreaterThan = true;
            lastDiff = 0;
        else
            lastGreaterThan = false;
            lastDiff = abs(itVals(lastItInd) - lastItVal);
        end
        vThresh = vThresh + incSize;
        
    else
        keepVirmen = false;
    end
end

%get frame info
fStart1 = fData(2:end) > 4; %find all indices where < 4
fStart2 = fData(1:end-1) < 4; %find all indices where > 4
fStartTimes = find(fStart1 == 1 & fStart2 == 1) + 1; %find changes from <4 to > 4, add 1 for diff
fEnd1 = fData(1:end-1) > 4; %find all indices where > 4
fEnd2 = fData(2:end) < 4;%find all indices where < 4
fStopTimes = find(fEnd1 == 1 & fEnd2 == 1) + 1; %find changes from >4 to <4, add 1 for diff

%make range
fRange = fStartTimes';
fRange(:,2) = [fStartTimes(2:end)-1 fStopTimes(end)]'; %use start times so that all iterations leading up to next frame are included
    
%get frame iteration ind
frameItInd = cell2mat(arrayfun(@(x) find(itTimes >= x,1,'first'),fRange(:,1),'UniformOutput',false));
frameItInd(:,2) = cell2mat(arrayfun(@(x) find(itTimes < x,1,'last'),fRange(:,2),'UniformOutput',false));

%convert to iteration numbers
frameItRanges = itVals(frameItInd);

%get iterations 
frameIterations = cellfun(@(x,y) x:y,num2cell(frameItRanges(:,1)),...
    num2cell(frameItRanges(:,2)),'UniformOutput',false);



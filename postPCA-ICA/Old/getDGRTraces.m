function traces = getDGRTraces(greenPath,redPath,filters,window,frameRate,percentileVal)
%getDGRTraces.m Function to extract dG/R traces
%
%INPUTS
%greenPath - path to green movie
%redPath - path to red movie
%filters - filters to use
%window - number of seconds for baseline window
%frameRate - number of frames per second
%percentileVal - percentile for baseline
%
%OUTPUTS
%traces - nFilters x nFrames array of dG/R traces
%
%ASM 3/14

%create waitbar
hWait = waitbar(0,'Loading green movie');

%load in green movie
greenTiff = loadtiffAM(greenPath);

%get green traces
greenTraces = getRawTraces(greenTiff,filters,hWait);

%clear green movie
clear greenTiff;

%load in red movie
waitbar(0.5,hWait,'Loading red movie');
redTiff = loadtiffAM(redPath);

%get red traces
redTraces = getRawTraces(redTiff,filters,hWait);

%clear red movie
clear redTiff;

%calculate window in frames
winFrames = window*frameRate;

%get baselines
greenBaseline = getMovingPercentile(greenTraces,percentileVal,winFrames,hWait);


redBaseline = zeros(size(greenBaseline));
for i = 1:size(redBaseline,1)
    redBaseline(i,:) = smooth(redTraces(i,:),round(winFrames*frameRate));
end

%get dF/R
traces = 100*(greenTraces - greenBaseline)./redBaseline;

%delete waitbar
delete(hWait);




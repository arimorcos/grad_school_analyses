function plotDeltaPLeftVsNetEv(deltaPLeft,netEv,limitSegNum,useAbs)
%plotDeltaPLeftVsEpoch.m Plots the change in p(left) as a function of maze
%epoch transition 
%
%INPUTS
%deltaPLeft.m Output of calcPLeftChange 
%netEv - nTrials x nSeg array of net evidence 
%limitSegNum - limit analysis to individual segment transition 
%useAbs - use absolute value of net evidence 
%
%ASM 6/15

if nargin < 4 || isempty(useAbs)
    useAbs = true;
end

if nargin < 3
    limitSegNum = [];
end

%crop last value of net ev and add zeros 
netEv = netEv(:,1:end-1);
netEv = cat(2,zeros(size(netEv,1),1),netEv);

%crop deltaPLeft 
deltaPLeft = deltaPLeft(:,1:size(netEv,2));
if ~isempty(limitSegNum) 
    deltaPLeft = deltaPLeft(:,limitSegNum);
    netEv = netEv(:,limitSegNum);
end

%convert to absolute value if necessary 
if useAbs
    netEv = abs(netEv);
end

%get unique net evidence conditions 
uniqueNetEv = unique(netEv(:));
nNetEv = length(uniqueNetEv);

%loop through and calculate mean and sem for each 
meanNetEv = nan(nNetEv,1);
semNetEv = nan(nNetEv,1);
for evInd = 1:nNetEv
    
    %get matching net evidence values 
    matchInd = netEv == uniqueNetEv(evInd);
    
    %get matching p(left)
    pLeftSub = deltaPLeft(matchInd);
    
    %take mean and sem 
    meanNetEv(evInd) = nanmean(abs(pLeftSub(:)));
    semNetEv(evInd) = calcSEM(abs(pLeftSub(:)));
end

%create figure and axis 
figH = figure;
axH = axes; 

%plot 
errH = shadedErrorBar(uniqueNetEv,meanNetEv,semNetEv);

%beautify 
beautifyPlot(figH,axH);

%tick labels 
axH.XTick = uniqueNetEv;

%label 
if useAbs
    axH.XLabel.String = 'Absolute Net Evidence';
else
    axH.XLabel.String = 'Net Evidence';
end
axH.YLabel.String = '\Delta P(Left Turn)';

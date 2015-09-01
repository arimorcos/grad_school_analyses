function handles = plotDeltaPLeftVsNetEv(deltaPLeft,netEv,limitSegNum,useAbs,handles)
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

%create figure and axis
if nargin < 5 || isempty(handles)
    handles.fig = figure;
    handles.ax = axes;
end

%turn on hold
hold(handles.ax,'on');

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
mazePatterns = cat(2,netEv(:,1),diff(netEv,1,2));
if ~isempty(limitSegNum) 
    deltaPLeft = deltaPLeft(:,limitSegNum);
    netEv = netEv(:,limitSegNum);
    mazePatterns = mazePatterns(:,limitSegNum);
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
    
    %take only left segment 
%     matchInd = matchInd & mazePatterns == -1;
    
    %get matching p(left)
    pLeftSub = deltaPLeft(matchInd);
    
    %take mean and sem 
    meanNetEv(evInd) = nanmean(abs(pLeftSub(:)));
    semNetEv(evInd) = calcSEM(abs(pLeftSub(:)));
%     meanNetEv(evInd) = nanmean(pLeftSub(:));
%     semNetEv(evInd) = calcSEM(pLeftSub(:));
end

%plot 
errH = errorbar(uniqueNetEv,meanNetEv,semNetEv);
errH.Marker = 'o';

%beautify 
beautifyPlot(handles.fig,handles.ax);

%tick labels 
handles.ax.XTick = uniqueNetEv;

%label 
if useAbs
    handles.ax.XLabel.String = 'Absolute Net Evidence';
else
    handles.ax.XLabel.String = 'Net Evidence';
end
handles.ax.YLabel.String = '\Delta P(Left Turn)';

%store
if isfield(handles,'errH')
    handles.errH(length(handles.errH)+1) = errH;
else
    handles.errH = errH;
end

%change color
nColors = length(handles.errH);
colors = distinguishable_colors(nColors);
for plotInd = 1:nColors
    handles.errH(plotInd).MarkerEdgeColor = colors(plotInd,:);
    handles.errH(plotInd).MarkerFaceColor = colors(plotInd,:);
    handles.errH(plotInd).Color = colors(plotInd,:);
end

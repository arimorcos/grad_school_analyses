function handles = plotSVRNetEvidence(classOut,handles,version)
%plotSVRGuessVsActual.m Plots a scatter plot of the
%
%INPUTS
%classOut - classifier output
%handles - array of handles
%
%OUTPUTS
%handles
%
%ASM 4/15

if nargin < 3 || isempty(version)
    version = 1;
end

if nargin < 2 || isempty(handles)
    handles.fig = figure;
    handles.ax = axes;
end
nSeg = 6;

%turn on hold
hold(handles.ax,'on');

%% plot ver 1
if version == 1
    
    uniqueVals = unique(classOut(1).testClass);
    meanVal = nan(1,length(uniqueVals));
    semVal = nan(size(meanVal));
    for i = 1:length(uniqueVals)
        meanVal(i) = mean(classOut(1).guess(classOut(1).testClass==uniqueVals(i)));
        semVal(i) = calcSEM(classOut(1).guess(classOut(1).testClass==uniqueVals(i)));
    end
    
    errMean = errorbar(uniqueVals+0.1*randn(size(uniqueVals)),...
        meanVal,semVal);
    % errMean = plot(uniqueVals,meanVal);
    errMean.MarkerEdgeColor = 'b';
    errMean.MarkerFaceColor = 'b';
    errMean.Color = 'b';
    errMean.Marker = 'o';
    errMean.LineStyle = 'none';
    errMean.MarkerSize = 10;
    errMean.LineWidth = 2;
    
    switch lower(classOut(1).classMode)
        case 'netev'
            handles.ax.XLabel.String = 'Actual Net Evidence';
            minVal = -nSeg-0.5;
        case 'numleft'
            handles.ax.XLabel.String = 'Actual Num Left';
            minVal = -.5;
        case 'numright'
            minVal = -.5;
            handles.ax.XLabel.String = 'Actual Num Right';
    end
    maxVal = nSeg+0.5;
    if isfield(classOut(1),'viewAngleRange') && classOut(1).binViewAngle
        minVal = -0.5;
    end
    handles.ax.XLim = [minVal maxVal];
    handles.ax.YLim = [minVal maxVal];
    
    
    handles.ax.YLabel.String = 'Mean Guess';
    
    %store
    if isfield(handles,'errMean')
        handles.errMean(length(handles.errMean)+1) = errMean;
    else
        handles.errMean = errMean;
        
        %plot unity line
        handles.unity = plot([minVal maxVal], [minVal maxVal],'k--');
        axis square;
    end
    
    %change color
    nColors = length(handles.errMean);
    colors = distinguishable_colors(nColors);
    for plotInd = 1:nColors
        handles.errMean(plotInd).MarkerEdgeColor = colors(plotInd,:);
        handles.errMean(plotInd).MarkerFaceColor = colors(plotInd,:);
        handles.errMean(plotInd).Color = colors(plotInd,:);
    end
    
end

%% plot version 2
if version == 2
    
    
    confInt = 95;
    
    %initialize
    mse = nan(1,3);
    corrCoef = nan(1,3);
    shuffleMSE = nan(3,3);
    shuffleCorrCoef = nan(3,3);
    
    %determine confidence interval range
    lowConf = (100 - confInt)/2;
    highConf = 100 - lowConf;
    
    %loop through each condition
    for condInd = 1:3
        
        %store data
        mse(condInd) = classOut(condInd).mse;
        corrCoef(condInd) = classOut(condInd).corrCoef;
        
        %get confidence intervals
        shuffleMSE(condInd,1) = median(classOut(condInd).shuffleMSE);
        shuffleMSE(condInd,2:3) = prctile(classOut(condInd).shuffleMSE,[lowConf,highConf]);
        shuffleMSE(condInd,2:3) = abs(bsxfun(@minus,shuffleMSE(condInd,2:3),shuffleMSE(condInd,1)));
        
        shuffleCorrCoef(condInd,1) = median(classOut(condInd).shuffleCorrCoef);
        shuffleCorrCoef(condInd,2:3) = prctile(classOut(condInd).shuffleCorrCoef,[lowConf,highConf]);
        shuffleCorrCoef(condInd,2:3) = abs(bsxfun(@minus,shuffleCorrCoef(condInd,2:3),...
            shuffleCorrCoef(condInd,1)));
    end
   
    hold(handles.ax,'on');
    
    %plot actual data for mse
    scatH = gobjects(1,3);
    for condInd = 1:3
        %get absolute difference
        absDiff = abs(classOut(condInd).guess - classOut(condInd).testClass);
        
        %take mean of squares
        mse = mean(absDiff.^2);
        
        scatH(condInd) = scatter(condInd,mse);
    end
    
    %plot shuffle
    errH = gobjects(1,3);
    for condInd = 1:3
        
        %get absolute difference
        guessDiff = classOut(condInd).shuffleGuess - classOut(condInd).shuffleTestClass;
        
        %take mean of squares
        mse = squeeze(mean(guessDiff.^2))';
        shuffleMed = median(mse);
        confInt = prctile(mse,[lowConf, highConf]);
        confInt = abs(confInt - shuffleMed);
        
        errH(condInd) = errorbar(condInd,shuffleMed,...
            confInt(1),confInt(2));
        errH(condInd).LineWidth = 2;
        errH(condInd).LineStyle = 'none';
    end
    
    %set labels
    handles.ax.XTick = 1:3;
    handles.ax.XTickLabel = {'All Trials','Left Net Evidence','Right Net Evidence'};
    handles.ax.YLabel.String = 'Mean Squared Error';
    %     handles.ax.Title.String = 'Guess vs. actual MSE';
    
    %store
    if isfield(handles,'errH')
        handles.errH{length(handles.errH)+1} = errH;
        handles.scatH{length(handles.scatH)+1} = scatH;
    else
        handles.errH = {errH};
        handles.scatH = {scatH};
        
        axis square;
    end
    
    %change color
    nColors = length(handles.errH);
    colors = distinguishable_colors(nColors);
    for plotInd = 1:nColors
        for condInd = 1:3
            handles.errH{plotInd}(condInd).Color = colors(plotInd,:);
            handles.scatH{plotInd}(condInd).MarkerEdgeColor = colors(plotInd,:);
            handles.scatH{plotInd}(condInd).MarkerFaceColor = colors(plotInd,:);
            
            %re-align 
            newX = linspace(condInd-0.3,condInd+0.3,nColors+2);
            newX = newX(2:end-1);
            handles.errH{plotInd}(condInd).XData = newX(plotInd);
            handles.scatH{plotInd}(condInd).XData = newX(plotInd);
        end
    end
    
    
end
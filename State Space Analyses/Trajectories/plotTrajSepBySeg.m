function plotTrajSepBySeg(dataCell,conditions,varargin)
%plotTrajSepBySeg.m Calculates trajectory separation and plots both total
%separation and change in separation due to each segment
%
%INPUTS
%dataCell - dataCell containing imaging data
%conditions - cell rray of condition strings
%
%OPTIONAL INPUTS
%whichFactors - which factors to calculate distance based upon
%whichFactorSet - which factor set to use
%binNums - 1 x nSeg + 1 array of binNumbers for start and stop of each
%   segment
%vectorRange - 1 x 2 array of fraction start and end bin for vector
%   calculation. Must be between 0 and 1
%
%ASM 1/15

%process varargin
whichFactorSet = 1;
whichFactors = 1:5;
distType = 'euclidean';
binNums = [10 26 42 58 74 90 106];
vectorRange = [0 1];
plotTraj = true;
plotSegVec = true;
segBins = 0:80:480;


if nargin > 1 || ~isempty(varargin)
    if isodd(length(varargin))
        error('Must provide a name and value for each argument');
    end
    for argInd = 1:2:length(varargin) %for each argument
        switch lower(varargin{argInd})
            case 'whichfactorset'
                whichFactorSet = varargin{argInd+1};
            case 'whichfactors'
                whichFactors = varargin{argInd+1};
            case 'disttype'
                distType = varargin{argInd+1};
            case 'vectorrange'
                vectorRange = varargin{argInd+1};
            case 'binnums'
                binNums = varargin{argInd+1};
            case 'plottraj'
                plotTraj = varargin{argInd+1};
            case 'plotsegvec'
                plotSegVec = varargin{argInd+1};
        end
    end
end

%check that conditions are valid 
for cond = conditions
    assert(any(findTrials(dataCell,cond{1})),'No trials matching %s',cond{1});
end

%calculate trajectory separation
trajSep = calcTrajSeparation(dataCell,conditions,'whichFactors',...
    whichFactors,'whichFactorSet',whichFactorSet,'distType',distType);

%get sep vectors
sepVectors = getTrajSepVectors(trajSep,vectorRange,binNums);

%% plot trajectory separation

if plotTraj
    %create mean trajectory plot
    figure; 
    axTraj = axes; 
    
    %calculate mean and std 
    meanTraj = mean(trajSep);
    semTraj = calcSEM(trajSep);
    
    %get bins 
    yPosBins = dataCell{1}.imaging.yPosBins;
    
    %plot 
    trajPlotH = shadedErrorBar(yPosBins,meanTraj,semTraj);
    
    %change color of error 
    trajPlotH.patch.FaceColor = 'r';
    trajPlotH.patch.FaceAlpha = 0.2;
    
    %add on segment lines
    for segNum = 1:length(segBins)
        line([segBins(segNum) segBins(segNum)],axTraj.YLim,'Color','k',...
            'LineStyle','--');
    end
    
    %set limits 
    axTraj.XLim = [min(yPosBins) max(yPosBins)];
    
    %set axes labels
    axTraj.XLabel.String = 'Y Position (binned)';
    axTraj.YLabel.String = 'Mean Trajectory Separation Distance';
    
    %set title 
    axTraj.Title.String = sprintf('Trajectory Separation Distance for conditions %s and %s',...
        conditions{:});
end

%% plot separation vectors 

if plotSegVec
   figure;
   axSeg = axes;
   
   %calculate mean and std
   meanSegVec = mean(sepVectors);
   semSegVec = calcSEM(sepVectors);
   
   %create bar chart
   barH = barwitherr(semSegVec, meanSegVec);
   barH.error.LineWidth = 2;
   
   %set prober tick labels
   axSeg.XTickLabel = 1:length(meanSegVec);
   
   %label axes
   axSeg.XLabel.String = 'Segment Number';
   axSeg.YLabel.String = 'Change in Trajectory Separation';
   
   %set title
   axSeg.Title.String = sprintf('Change in Trajectory Separation Distance for conditions %s and %s',...
       conditions{:});
   
end

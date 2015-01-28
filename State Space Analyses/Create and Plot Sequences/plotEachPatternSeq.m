function figH = plotEachPatternSeq(dataCell,varargin)
%plotEachPatternSeq.m Plots every pattern of evidence sequence plot
%
%INPUTS
%dataCell - dataCell containing imaging and integration data
%
%OUTPUTS
%figH - figure handle
%
%ASM 10/14

normVal = 'cells';
cMap = 'jet';
showTitle = false;

%process varargin
if nargin > 1 || ~isempty(varargin)
    if isodd(length(varargin))
        error('Must provide a name and value for each argument');
    end
    for argInd = 1:2:length(varargin) %for each argument
        switch lower(varargin{argInd})
            case 'normval'
                normVal = varargin{argInd+1};
            case 'cmap'
                cMap = varargin{argInd+1};
            case 'showtitle'
                showTitle = varargin{argInd+1};
        end
    end
end

%get number of patterns
mazePatterns = getMazePatterns(dataCell);
mazePatterns = unique(mazePatterns,'rows');
nPatterns = size(mazePatterns,1);

% create figure 
figH = figure;

%calculate number of plots
[nRows,nCol] = calcNSubplotRows(nPatterns);
if showTitle
    yGap = 0.03;
else
    yGap = 0.0075;
end
axH = tight_subplot(nRows,nCol,[yGap 0.0075],0.02,0.02);

%plot
for patternInd = 1:nPatterns
    
    dispProgress('Creating sequence plot %d/%d',patternInd,patternInd,nPatterns);
    
    currAx = axH(patternInd);
    axes(currAx);
    
    %plot sequence
    makeLeftRightSeq(dataCell,normVal,{['[ ',...
        num2str(mazePatterns(patternInd,:)),' ]']},false,[],currAx);
    
    %turn of ticks
    currAx.XTickLabel = [];
    currAx.YTickLabel = [];
    
    %title
    if showTitle
        title(num2str(mazePatterns(patternInd,:)),'FontSize',10);
    end
    
    %set colormap
    colormap(cMap);
   
end

%delete extra axes
delete(axH(nPatterns+1:end));

suplabel('Y Position (Binned)','x');
suplabel('Cell # (sorted independently)','y');
    

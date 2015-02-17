function animateActivityAndTrace(tiff,roiInfo,traces,roiInd,vidPath)
%animateActivityAndTrace.m Creates animation of neuronal activity and the
%trace on the side
%
%INPUTS
%tiff - height x width x nFrames tiff array
%roiInfo - roi structure output by acq2p
%traces - nROI x nFrames array of activity. Frames should match frames in
%   tiff
%roiInd - scalar of which roi to plot
%
%OUTPUTS
%figH - figure handle
%
%ASM 2/15

if nargin < 5 
    vidPath = [];
end

%check inputs
assert(size(tiff,3) == size(traces,2),'Traces and tiff must have same number of frames');
assert(length(roiInfo) == size(traces,1),'Traces and roiInfo must have same number of rois');
for whichROI = 1:length(roiInd)
    assert(roiInd(whichROI) <= length(roiInfo) & roiInd(whichROI) > 0,...
        'roiInd must be within roi range');
    assert(round(roiInd(whichROI)) == roiInd(whichROI),'roiInd must be a scalar');
end

%get nFrames
nFrames = size(tiff,3);

%adjust mean intensity of tiff to be equal
meanFrameIntensity = mean(reshape(tiff(1:100,1:100,:),100^2,nFrames));
for frameInd = 1:nFrames
    tiff(:,:,frameInd) = tiff(:,:,frameInd)/meanFrameIntensity(frameInd);
end

%extract relevant traces
currTraces = traces(roiInd,:);


for whichROI = 1:length(roiInd)
    currROI = roiInfo(roiInd(whichROI));
    
    %get border of current roi
    roiImage = zeros(size(tiff(:,:,1)));
    roiImage(currROI.indBody) = 1;
    [roiRow{whichROI}, roiCol{whichROI}] = findEdges(roiImage);
    roiStats = regionprops(roiImage,'Centroid');
    roiCentroid(whichROI,:) = roiStats.Centroid;
    
    %shift patch outwards
    pixShift = 0;
    for pixInd = 1:length(roiRow{whichROI})
        if roiRow{whichROI}(pixInd) <= roiCentroid(1)
            roiRow{whichROI}(pixInd) = roiRow{whichROI}(pixInd) - pixShift;
        else
            roiRow{whichROI}(pixInd) = roiRow{whichROI}(pixInd) + pixShift;
        end
        if roiCol{whichROI}(pixInd) <= roiCentroid(2)
            roiCol{whichROI}(pixInd) = roiCol{whichROI}(pixInd) - pixShift;
        else
            roiCol{whichROI}(pixInd) = roiCol{whichROI}(pixInd) + pixShift;
        end
    end
end

%create figure
figH = figure;
figH.Color = 'w';

%generate colors
colors = distinguishable_colors(length(roiInd));

%create tiff zoom out plot
axTiffZoomOut = subplot_tight(2,2,1,[0.02 0.02]);
tiffImgZoomOut = imagesc(tiff(:,:,1));
colormap(gray);
axis image;
axTiffZoomOut.XTick = [];
axTiffZoomOut.YTick = [];

%overlay roi
hold(axTiffZoomOut,'on');
for whichROI = 1:length(roiInd)
    tiffROI = patch(roiRow{whichROI}, roiCol{whichROI},[1 0 0],'Parent', axTiffZoomOut);
    tiffROI.FaceAlpha = 0;
    tiffROI.EdgeColor = colors(whichROI,:);
end

%create tiff zoom out plot
axTiffZoomIn = subplot_tight(2,2,2,[0.02 0.02]);
tiffImgZoomIn = imagesc(tiff(:,:,1));
colormap(gray);
axis image;
axTiffZoomIn.XTick = [];
axTiffZoomIn.YTick = [];

%overlay roi
hold(axTiffZoomIn,'on');
for whichROI = 1:length(roiInd)
    tiffROI = patch(roiRow{whichROI}, roiCol{whichROI},[1 0 0],'Parent', axTiffZoomIn);
    tiffROI.FaceAlpha = 0;
    tiffROI.EdgeColor = colors(whichROI,:);
end

%set limits for zoomed in image
zoomRange = 75;
axTiffZoomIn.XLim = [min(roiCentroid(:,1)) - zoomRange max(roiCentroid(:,1)) + zoomRange];
axTiffZoomIn.YLim = [min(roiCentroid(:,2)) - zoomRange max(roiCentroid(:,2)) + zoomRange];

%create animated line
axTrace = subplot_tight(2,1,2,[0.09 0.06]);
hold(axTrace,'on');
axTrace.XLabel.String = 'Frame #';
axTrace.YLabel.String = 'dF/F';
for whichROI = 1:length(roiInd)
    traceLine(whichROI) = animatedline;
    traceLine(whichROI).Color = colors(whichROI,:);
end
axTrace.XLim = [1 nFrames];
axTrace.YLim = [min(currTraces(:)) max(currTraces(:))];
axTrace.FontSize = 20;
axTrace.FontName = 'Yu Gothic';

%maximize figure
maxfig(figH,1);
drawnow;

pause(0.1);

%initialize movie array
if ~isempty(vidPath)
    if exist(vidPath,'file')
        delete(vidPath);
    end    
    vidWrite = VideoWriter(vidPath);
    open(vidWrite);
end

%play movie
for frameInd = 1:nFrames
    
    %update tiff
    tiffImgZoomOut.CData = tiff(:,:,frameInd);
    tiffImgZoomIn.CData = tiff(:,:,frameInd);
    
    %update line
    for whichROI = 1:length(roiInd)
        addpoints(traceLine(whichROI),frameInd,currTraces(whichROI,frameInd));
    end
    
    %force draw now 
    drawnow;
    
    %store frame
    if ~isempty(vidPath)
        currFrame = getframe(figH);
        writeVideo(vidWrite,currFrame);
    else 
        %pause for a moment
        pause(0.02);
    end
    
end

if ~isempty(vidPath)
    close(vidWrite);
end
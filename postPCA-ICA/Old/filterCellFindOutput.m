function out = filterCellFindOutput(cellFind,base)
%filterCellFindOutput.m Function to create graphical filter of cell find
%output to allow quick removal of non-cell ROIs
%
%INPUTS
%cellFind - output of visor_find_cell_center.m 
%base - original image
%
%OUTPUTS
%out - new output without removed ROIs
%
%ASM 3/14

%get nROIs
nROIs = length(cellFind.ROI);

%create figure
sortFig = figure('Name','Filter Cell Finder Output');
ROIAx = subplot(1,2,1);
baseAx = subplot(1,2,2);
maxfig(sortFig,1); %maximize

%initialize out
out = cellFind;
xPos = [];
yPos = [];
buttonPressed = [];

while ishandle(sortFig) %while figure is open
    
   %plot ROIs
   axes(ROIAx);
   imagesc(sum(out.ROI,3));
   colormap(gray);
   axis square;       
   
   %plot base
   axes(baseAx)
   imagesc(base.^0.25);
   colormap(gray);
   axis square;
   hold on;
   plot(xPos,yPos,'r*','MarkerSize',10);
   
   %get ginput
   axes(ROIAx);
   try
       [xPos,yPos,buttonPressed] = ginput(1);
   end
   
   if buttonPressed == 1 %if left click
       %find closest ROI
       dists = zeros(1,size(out.ROI,3));
       for i = 1:size(out.ROI,3) %for each ROI
           dists(i) = calcEuclidianDist([xPos yPos],out.centers(i,:));
       end
       [~,delInd] = min(dists);
       out.centers(delInd,:) = [];
       out.ROI(:,:,delInd) = [];
       
       xPos = [];
       yPos = [];
       
   end
    
    
end
function figH = showCompleteTransitionMatrix(dataCell,clusters,colorBy)
%showCompleteTransitionMatrix.m Plots a transition matrix of the complete
%graph defined in the first cell of dataCell
%
%INPUTS
%dataCell - dataCell containing clustered data
%clusters - nPoints x 1 array of cluster identities
%colorBy - variable to color by
%
%ASM 4/15

[pngPath,colorPossibilities,clusterVal] = createClusterTransMatPNG(dataCell,clusters,colorBy);

%create figure and plot
figure;
imshow(pngPath,'InitialMagnification','fit');
colormap(colorPossibilities);
cBar = colorbar;
cBar.Label.String = colorBy;
cBar.TickLabels = cBar.Ticks*range(clusterVal) + min(clusterVal);

end


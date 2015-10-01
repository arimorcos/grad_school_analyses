
exportLoc = 'D:\DATA\Analyzed Data\150925_vogel_nonSelectivePDF\AM144_141204_crossVal_SVM';

%loop through each neuron and plot
for neuronInd = 1:length(useNeurons)
    
    %dispProgress
    dispProgress('Processing neuron %d/%d',neuronInd,neuronInd,length(useNeurons));
    
    %create plot
    figH = plotMeanActivity(imTrials,{'maze.numLeft==6','maze.numLeft==0'},...
        useNeurons(neuronInd),{'Left 6-0 trial #','Right 0-6 trial #'});
    
    %maximize
    set(figH,'Units','Normalized','OuterPosition',[0 0 1 1],'PaperPositionMode','auto');
    
    %save figure
%     if neuronInd == 1
%         export_fig(figH,exportLoc,'-pdf','-transparent','-nocrop');
%     else
%         export_fig(figH,exportLoc,'-pdf','-transparent','-nocrop','-append');
%     end
    toPPT(figH)
    
    %delete figure
    delete(figH);
end

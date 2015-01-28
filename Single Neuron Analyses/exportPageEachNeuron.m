function exportPageEachNeuron(dataCell,plotFunc,exportLoc)
%exportPageEachNeuron.m Function which exports a page for every neuron to a
%pdf using the plotFunc provided
%
%INPUTS
%dataCell - dataCell containing imaging data
%plotFunc - function handle to use to plot with optional arguments in cell
%   array. Must output figure handle
%exportLoc - location to export to
%
%ASM 10/14

%get imTrials if not provided
imTrials = getTrials(dataCell,'imaging.imData==1');

%get number of neurons
nNeurons = size(imTrials{1}.imaging.dFFTraces{1},1);

%parse plotFunction
if ~iscell(plotFunc)
    plotFunc = {plotFunc};
end

%delete file if exists
if exist(exportLoc,'file')
    delete(exportLoc);
end

%loop through each neuron and plot
for neuronInd = 1:nNeurons
    
    %dispProgress
    dispProgress('Processing neuron %d/%d',neuronInd,neuronInd,nNeurons);
    
    %create plot
    figH = feval(plotFunc{:},'cellid',neuronInd);
    
    %maximize
    set(figH,'Units','Normalized','OuterPosition',[0 0 1 1],'PaperPositionMode','auto');
    
    %save figure
    if neuronInd == 1
        export_fig(figH,exportLoc,'-pdf','-transparent','-nocrop');
    else
        export_fig(figH,exportLoc,'-pdf','-transparent','-nocrop','-append');
    end
    
    %delete figure
    delete(figH);
end

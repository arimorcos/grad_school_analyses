function trials60 = shuffleCellAssociationsWithin60(dataCell)
%shuffleCellAssociationsWithin60.m Shuffles cell associations on a
%trial-by-trial basis separately within 6-0 left and 0-6 right trials. In
%other words, for each cell the trial association is shuffled within each
%trial type. 
%
%INPUTS
%dataCell 
%
%OUTPUTS
%shuffleCell - cell with shuffled associations 
%
%ASM 10/15

%subset to 60 trials 
trials60 = getTrials(dataCell,'maze.numLeft==0,6;result.correct==1');

%get deconv traces 
traces = catBinnedDeconvTraces(trials60);

%get leftTrials 
leftTrials = getCellVals(trials60,'result.leftTurn');

%get nNeurons 
nNeurons = size(traces,1);

%shuffle neruons 
leftTrialKey = find(leftTrials);
rightTrialKey = find(~leftTrials);
for neuron = 1:nNeurons
    
    %shuffle each 
    shuffleLeftKey = shuffleArray(leftTrialKey);
    shuffleRightKey = shuffleArray(rightTrialKey);
    
    %reassign 
    traces(neuron,:,leftTrialKey) = traces(neuron,:,shuffleLeftKey);
    traces(neuron,:,rightTrialKey) = traces(neuron,:,shuffleRightKey);
    
end

% traces = traces(1:100,:,:);

%copy back in to dataCell 
nTrials = size(traces,3);
for trial = 1:nTrials 
    trials60{trial}.imaging.binnedDeconvTraces{1} = traces(:,:,trial);
end

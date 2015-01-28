function [selectivity,sig] = findTrialTypeSelective(dataCell,nShuffles,confBound)
%findTrialTypeSelective.m Calculates selectivity index across the whole
%trial
%
%INPUTS
%dataCell
%nShuffles
%confBound
%
%OUTPUTS
%selectivity
%sig


%establish conditions
conditions = {'maze.crutchTrial==0;result.correct==1;maze.numLeft==0,6;result.leftTurn==1',...
              'maze.crutchTrial==0;result.correct==1;maze.numLeft==0,6;result.leftTurn==0'};
          
          
%get imSub
imSub = getTrials(dataCell,'imaging.imData == 1');

%bin if necessary
if ~isfield(imSub{1}.imaging,'binnedDFFTraces')
    imSub = binFramesByYPos(imSub,binSize);
end

%get dFFtraces
dFFTraces = catBinnedTraces(imSub);

%get sort by cond
cond1Trials = findTrials(imSub,conditions{1});
cond2Trials = findTrials(imSub,conditions{2});
nCond1 = sum(cond1Trials);


%get traces subsets
cond1Traces = dFFTraces(:,:,cond1Trials);
cond2Traces = dFFTraces(:,:,cond2Trials);

%reshape
cond1Traces = reshape(size(cond1Traces,1),size(cond1Traces,2)*size(cond1Traces,3));
cond2Traces = reshape(size(cond2Traces,1),size(cond2Traces,2)*size(cond2Traces,3));

%get mean
cond1Mean = mean(cond1Traces,2);
cond2Mean = mean(cond2Traces,2);

%get selectivity for each neuron
selectivity = (cond1Mean - cond2Mean)./(cond1Mean+cond2Mean);

%shuffle
shuffleSel = zeros(nShuffles,length(selectivity));
for i =1:nShuffles
    
    

end
    
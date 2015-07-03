function coeff = calculateTrialTrialVarCoefficient(dataCell)
%calculateTrialTrialVarCoefficient.m Calculates coefficient of
%trial-to-trial variability on 6-0 trials. Takes the average of the
%trial-to-trial correlation matrix for left and right 6-0 trials
%independently.
%
%INPUTS
%dataCell - dataCell containing imaging data
%
%OUTPUTS 
%coeff - nNeurons x 1 array of coefficients. 1 is most trial-to-trial
%   variability, 0 is no trial-to-trial variability
%
%ASM 7/15

%get left and right 60
left60 = getTrials(dataCell,'result.correct==1;maze.numLeft==6');
right60 = getTrials(dataCell,'result.correct==1;maze.numLeft==0');

%get binned traces 
[~,leftTraces] = catBinnedTraces(left60);
[~,rightTraces] = catBinnedTraces(right60);

%crop out beginning and end 
leftTraces = leftTraces(:,2:end-1,:);
rightTraces = rightTraces(:,2:end-1,:);

%get nNeurons
nNeurons = size(leftTraces,1);

%loop through each neuron and calculate 
coeff = nan(nNeurons,1);
for neuron = 1:nNeurons
    
    %create correlation matrix 
    leftCoeff = nanmean(pdist(squeeze(leftTraces(neuron,:,:))','correlation'));
    rightCoeff = nanmean(pdist(squeeze(rightTraces(neuron,:,:))','correlation'));
    
    %take min 
    coeff(neuron) = min(1,min(leftCoeff,rightCoeff));
end
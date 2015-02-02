function plotVectorMagnitude(segVectors,varToUse,varOp)
%plotVectorMagnitude.m Plots vector magnitude as a function of provided
%variable. 
%
%INPUTS
%segVectors - segVectorTable outputted by getSegVectors
%varToUse - name of variable to use as x-axis
%
%ASM 1/15

if nargin < 3
    varOp = [];
end

%check that segVectors is a table 
assert(istable(segVectors),'segVectors must be a table');

%check that varToUse matches variable in table
assert(any(strcmpi(varToUse,segVectors.Properties.VariableNames)),...
    '"%s" is not a valid variable name',varToUse);


%get variable values
varVals = segVectors.(varToUse);

%perform operation if necessary 
if isa(varOp,'function_handle')
    varVals = varOp(varVals);
end

%extract unique conditions for given variable 
uniqueVals = unique(varVals);
nUniqueVals = length(uniqueVals);

%loop through each unique value and get corresponding dataset
vectorSubs = cell(1,nUniqueVals);
for valInd = 1:nUniqueVals
    
    %extract relevant vectors 
    tempVectors = segVectors{varVals == uniqueVals(valInd),'vector'};
    
    %concatenate and store
    vectorSubs{valInd} = cat(2,tempVectors{:});
    
end

%get magnitude of each vector 
getMagnitude = @(x) sqrt(sum(x.^2));
vectorMags = cellfun(getMagnitude, vectorSubs, 'UniformOutput', false);

%compute mean and sem of each 
meanMag = cellfun(@mean,vectorMags);
semMag = cellfun(@calcSEM,vectorMags);

%%%% plot

%create figure
figH = figure; 
axH = axes;

%create bar chart 
barH = barwitherr(semMag, meanMag);
barH.error.LineWidth = 2;

%set prober tick labels 
axH.XTickLabel = uniqueVals;

%label axes 
axH.XLabel.String = varToUse;
axH.YLabel.String = 'Vector Magnitude';
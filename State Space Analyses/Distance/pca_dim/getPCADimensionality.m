function dim = getPCADimensionality(dataCell, which_var)
%getPCADimensionality. Performs PCA at each epoch and outputs the number of
%dimensions required to get to a given variance threshold 
%
%INPUTS
%dataCell - dataCell containging imaging data
%which_var - array of variances to test
%
%OUTPUTS
%dim - num_variances x num_epochs array of number of dimensions required to
%   reach the criterion variance
%
%ASM 3/16

mean_subtract = true;
std_normalize = true;

if any(which_var > 1)
    which_var = which_var/100;
end

%get traces 
traces = catBinnedDeconvTraces(dataCell);

% mean subtract 
if mean_subtract
    mean_vals = nanmean(reshape(traces, size(traces, 1), []), 2);
    if std_normalize
        std_vals = nanstd(reshape(traces, size(traces, 1), []), 0, 2);
    end
    traces = traces - repmat(mean_vals, 1, size(traces, 2), size(traces,3));
    if std_normalize
        traces = traces./repmat(std_vals, 1, size(traces, 2), size(traces,3));
    end
end

%get yPosBins
yPosBins = dataCell{1}.imaging.yPosBins;

%get maze points 
mazePoints = getMazePoints(traces, yPosBins, [0.5 0.75]);

%get num epochs 
num_epochs = size(mazePoints, 2);

%initialize 
num_var = length(which_var);
dim = nan(num_var, num_epochs);

%loop and calculate 
for epoch = 1:num_epochs
    
    temp_traces = squeeze(mazePoints(:, epoch, :));
    
    %do pca 
    [~, ~, eigenvals] = pca(temp_traces);
    
    %get cumulative variance
    cum_var = cumsum(eigenvals)./sum(eigenvals);
    
    %loop through each var
    for var = 1:num_var
        dim(var, epoch) = find(cum_var >= which_var(var), 1, 'first');
    end
end
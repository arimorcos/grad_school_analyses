function trans_rate = get_transients_per_min(dataCell)
%get_transients_per_min.m Calculates the number of calcium transients per
%minute using the raw df/f data 
%
%INPUTS
%dataCell - containing imaging data 
%
%OUTPUTS
%trans_rate - nCells x 1 vector containing the mean number of transients
%   per minute 
%
%ASM 6/16

%get frame rate
frame_rate = 1/dataCell{1}.sImage.scanFramePeriod;

% get dff trace
% dFFTrace = dataCell{1}.imaging.completeDFFTrace;
dFFTrace = dataCell{1}.imaging.completeDeconvTrace;

% get size 
[num_neurons, num_frames] = size(dFFTrace);

% get total time 
num_sec = num_frames / frame_rate; 
num_min = num_sec / 60;

% initialize 
num_transients = nan(num_neurons, 1);

% % smooth 
% smooth_length = 6;
% dFFTrace = arrayfun(@(x) smooth(dFFTrace(x,:), smooth_length)',...
%     1:num_neurons,'UniformOutput',false);
% dFFTrace = cat(1, dFFTrace{:});

for neuron_ind = 1:num_neurons

    %find continuous regions 
    [start,~] = findContinuousRegions(dFFTrace(neuron_ind,:), 0.04);
    
    diff_start = diff(start);
    
%     num_transients(neuron_ind) = length(start);
    frame_thresh = 5;
    num_transients(neuron_ind) = sum(diff_start > frame_thresh);
    
end

trans_rate = num_transients / num_min;



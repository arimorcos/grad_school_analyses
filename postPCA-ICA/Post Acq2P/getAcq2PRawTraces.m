function [traces, rawF, roi, traceNeuropil] = getAcq2PRawTraces(acq,ignoreGroup)
%getAcq2PRawTraces.m extracts roi using extractROIsBin and saves 
%
%INPUTS
%acq - acquisition object
%ignoreGroup - array of groups to ignore
%
%OUTPUTS
% traces - matrix of n_cells x n_frames fluorescence values, using neuropil correction for ROIs with a matched neuropil ROI
% rawF - matrix of same size as traces, but without using neuropil correction
% roi - roi strcuture 

if nargin < 2 || isempty(ignoreGroup)
    ignoreGroup = [];
end

%print 
fprintf('Extracting roi traces...');

%extract rois
[~, traces, rawF, roi, traceNeuropil] = extractROIsBin(acq,setdiff(1:9,ignoreGroup),1,1);
fprintf('Complete\n');

%get save location
saveLoc = fullfile(acq.defaultDir,[acq.acqName,'_extractedTraces.mat']);

%save
fprintf('Saving traces...');
save(saveLoc,'traces','rawF','traceNeuropil','roi');
fprintf('Complete\n');
function [cosine_sim, shuffle_cosine_sim] = ...
    get_cosine_sim_curr_prev_choice_hyperplane(dataCell)
%get_cosine_sim_curr_prev_choice_hyperplane.m Calculates the cosine
%similarity between the current and previous choice hyperplanes. 
%
%INPUTS
%dataCell - dataCell containing imaging data
%
%OUTPUTS
%cosine_sim - scalar cosine_similarity 
%shuffle_cosine_sim - values of cosine similarity with shuffled decision
%   planes
%
%ASM 3/16

which_bin = 50;
num_shuffles = 1000;

%get traces 
traces = catBinnedDeconvTraces(dataCell);
traces = squeeze(traces(:, which_bin, :))';

%get labels 
leftTurn = getCellVals(dataCell, 'result.leftTurn');
prevTurn = getCellVals(dataCell, 'result.prevTurn');

%fit models 
mdl_choice = fitcsvm(traces, leftTurn, 'Standardize', true);
mdl_prev_choice = fitcsvm(traces, prevTurn, 'Standardize', true);

%calc cosine sim 
cosine_sim = calc_cosine_sim(mdl_choice.Beta, mdl_prev_choice.Beta);

%shuffle 
shuffle_cosine_sim = nan(num_shuffles, 1);
trial_array = 1:length(dataCell);
for shuffle_ind = 1:num_shuffles
    
    shuffle_array = shuffleArray(trial_array);
    
    mdl_choice_shuffle = fitcsvm(traces, leftTurn(shuffle_array),...
        'Standardize', true);
    mdl_prev_choice_shuffle = fitcsvm(traces, prevTurn(shuffle_array),...
        'Standardize', true);
    
    %calc cosine sim
    shuffle_cosine_sim(shuffle_ind) = calc_cosine_sim(mdl_choice_shuffle.Beta,...
        mdl_prev_choice_shuffle.Beta);
    
end
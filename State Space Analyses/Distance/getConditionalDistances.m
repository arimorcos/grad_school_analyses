function out = getConditionalDistances(dataCell)
%getConditionalDistances.m Calculates the mean variance, mean pairwise
%distance, and mean pairwise cosine distance for all trials, left/right
%trials, left/right 6-0 trials, left/right 6-0 trials with same previous
%choice, left/right 6-0 trials with same previous choice and reward. 
%
%INPUTS 
%dataCell - dataCell containing imaging data
%
%OUTPUTS
%out - structure containing: 
%   conditions - list of condition labels
%   mean_variance - 10 x num_conditions array of mean variance across
%       neurons
%   mean_distance - 10 x num_conditions array of mean pairwise euclidean 
%       distance 
%   mean_cosine_distance - 10 x num_conditions array of mean pairwise cosine
%       distance (1 - cosine similarity)
%
%ASM 2/16

range = [0.5 0.75];
yPosBins = dataCell{1}.imaging.yPosBins;
dataCell = getTrials(dataCell, 'result.correct==1');

% set condition labels 
out.conditions = {'All correct trials',...
                  'Same choice',...
                  'Same 6-0 choice', ...
                  'Same 6-0 choice, same previous choice',...
                  'Same 6-0 choice, same previous choice and reward'};

% set condition specifications (cell array of cell arrays)
cond_specs = {{''},...
              {'result.leftTurn==1','result.leftTurn==0'},...
              {'maze.numLeft==0', 'maze.numLeft==6'},...
              {'maze.numLeft==0;result.prevTurn==1', 'maze.numLeft==6;result.prevTurn==1',...
               'maze.numLeft==0;result.prevTurn==0', 'maze.numLeft==6;result.prevTurn==0'},...
              {'maze.numLeft==0;result.prevTurn==1;result.prevCorrect==1',...
               'maze.numLeft==6;result.prevTurn==1;result.prevCorrect==1',...
               'maze.numLeft==0;result.prevTurn==0;result.prevCorrect==1',...
               'maze.numLeft==6;result.prevTurn==0;result.prevCorrect==1',...
               'maze.numLeft==0;result.prevTurn==1;result.prevCorrect==0',...
               'maze.numLeft==6;result.prevTurn==1;result.prevCorrect==0',...
               'maze.numLeft==0;result.prevTurn==0;result.prevCorrect==0',...
               'maze.numLeft==6;result.prevTurn==0;result.prevCorrect==0'}};

num_conditions = length(cond_specs);
           
% initialize 
out.mean_variance = nan(10, num_conditions);
out.mean_distance = nan(10, num_conditions);
out.mean_cosine_distance = nan(10, num_conditions);

% loop through each condition 
for cond = 1:num_conditions
    out = calc_features(out, dataCell, cond_specs{cond}, cond, yPosBins, range);    
end

end 

function out = calc_features(out, dataCell, conditions, ind, yPosBins, range)

% get number of conditions 
num_conditions = length(conditions);

%initialize
temp_variance = nan(10, num_conditions);
temp_distance = nan(10, num_conditions);
temp_cosine_distance = nan(10, num_conditions);

% loop through each condition 
for cond = 1:num_conditions
    % subset 
    sub = getTrials(dataCell, conditions{cond});

    if isempty(sub)
        continue;
    end
    
    % get traces 
    traces = catBinnedDeconvTraces(sub);
    traces = getMazePoints(traces, yPosBins, range);

    % loop through each point 
    for point = 1:10

        % get variance 
        temp_variance(point, cond) = ...
            get_mean_variance(squeeze(traces(:, point, :)));

        % get pairwise distance
        temp_distance(point, cond) = ...
            get_mean_pairwise_distance(squeeze(traces(:, point, :)));

        % get pairwise distance
        temp_cosine_distance(point, cond) = ...
            get_mean_cosine_distance(squeeze(traces(:, point, :)));
    end
end

out.mean_variance(:, ind) = nanmean(temp_variance, 2);
out.mean_distance(:, ind) = nanmean(temp_distance, 2);
out.mean_cosine_distance(:, ind) = nanmean(temp_cosine_distance, 2);


end

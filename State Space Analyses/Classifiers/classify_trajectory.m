function [trajectory_stim_classification,trajectory_stim_distances] = classify_trajectory(stimulus_trajectory);

trial_inds = 1:size(stimulus_trajectory,1);

for trial = 1:size(stimulus_trajectory,1);
    trialsforcentroid = find(trial_inds~=trial);
    time_centroid = squeeze(mean(stimulus_trajectory(trialsforcentroid,:,:,:)));  %%for the trials except for the test trial
    for stim = 1:size(stimulus_trajectory,3);  %%for each stimulus in that trial, find distance to those centroids
        for s = 1:size(stimulus_trajectory,3);
            for cel = 1:size(stimulus_trajectory,2)
                on_temp(cel,:) = (squeeze(time_centroid(cel,s,:)) - squeeze(stimulus_trajectory(trial,cel,stim,:))).^2;
            end
            trajectory_centroid_distance(s,:) = squeeze(sqrt(sum(on_temp)));


        end
        [x,y] = min(trajectory_centroid_distance);
        trajectory_stim_classification(trial,stim,:) = y;
       
        trajectory_stim_distances(trial,stim,:,:) = trajectory_centroid_distance;

    end
end

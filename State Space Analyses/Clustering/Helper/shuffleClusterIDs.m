function shuffleIDs = shuffleClusterIDs(clusterIDs)

shuffleIDs = nan(size(clusterIDs));
for point = 1:size(clusterIDs,2)
    shuffleIDs(:,point) = shuffleArray(clusterIDs(:,point));
end
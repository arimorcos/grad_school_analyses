function out = remapClusterIDs(in, separate)

if nargin < 2 || isempty(separate)
    separate = true;
end

out = in;

if separate
    for i = 1:size(in,2)
        uniqueClusters = unique(in(:,i));
        for clust = 1:length(uniqueClusters)
            out(in(:,i) == uniqueClusters(clust),i) = clust;
        end
    end
else
    uniqueClusters = unique(in(:));
    for clust = 1:length(uniqueClusters)
        out(in == uniqueClusters(clust)) = clust;
    end
end
function pngPath = convertTransMatToGraphViz(transMat,colors)
%convertTransMatToGraphViz.m Converts a transition matrix to a graph viz
%document 
%
%INPUTS
%transMat - nNodes x nNodes transition matrix 
%colors - nClusters x 3 hsv matrix of colors
%clusterSize - fraction of trials in cluster
%
%OUTPUTS
%gvPath - path to graphviz document
%
%ASM 4/15

%set gvPath 
gvPath = fullfile(cd,'temp.gv');
sccPath = fullfile(cd,'tempSCC.gv');
pngPath = fullfile(cd,'temp.png');

%get maxWeight
totalWeight = 10;
% totalNodeSize = 1e4;

%open file 
fid = fopen(gvPath,'w+');
nClusters = length(transMat);

%add opening 
fprintf(fid,'digraph G { \n');

%designate size 
fprintf(fid,'size = "100,100";\n'); 
fprintf(fid,'page = "8.5,11";\n'); 
fprintf(fid,'ratio = compress;\n'); 

%create each node
for clusterInd = 1:nClusters
    luminance = .5*max(colors(clusterInd,:)) + 0.5*min(colors(clusterInd,:));
    if luminance > 0.5
        currFontColor='black';
    else
        currFontColor='white';
    end
    fprintf(fid,sprintf(['%d [style=filled,fillcolor="%.3f,%.3f,%.3f",'...
        'fontcolor=%s,color=black];\n'],...
        clusterInd,rgb2hsv(colors(clusterInd,:)),currFontColor));
end

%loop through each combination and print 
for startCluster = 1:nClusters 
    for endCluster = 1:nClusters
        if transMat(startCluster,endCluster) > 0 
            currWeight = transMat(startCluster,endCluster)*totalWeight;
            fprintf(fid,'%d -> %d [penwidth=%.3f];\n',startCluster, endCluster,...
                currWeight);
        end
    end
end

%close bracket 
fprintf(fid,'}');

%close file
fclose(fid);

%create png 
addPathStr = 'PATH=/Users/arimorcos/anaconda/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/git/bin';
if exist(sccPath,'file')
    delete(sccPath);
end
command = sprintf('%s;sccmap -o %s %s',addPathStr,...
    strrep(sccPath,' ','\ '),strrep(gvPath,' ','\ '));
[status,out] = system(command);
command = sprintf('%s;dot -Tpng %s -o %s',addPathStr,...
    strrep(sccPath,' ','\ '),strrep(pngPath,' ','\ '));
[status,out] = system(command);


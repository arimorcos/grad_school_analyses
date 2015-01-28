function [cx,cy,r]=findInscribedCircle(x,y)
% by Tolga Birdal
% A sample application and a function for solving the maximum inscribed
% circle problem. 
% Unlike my other submission "Maximum Inscribed Circle using Distance 
% Transform", this algorithm is subpixel accurate. It operates only on the
% polygon and not the image points. Therefore, if the polygon is given in
% sub-pixels, the result will be accurate. 
% I use an O(n log(n)) algorithm as follows:
% Construct the Voronoi Diagram of the polygon.
% For Voronoi nodes which are inside the polygon:
%       Find the node with the maximum distance to edges in P. This node is
%       the centre of the maximum inscribed circle.
% 
% For more details on the problem itself please checkout my previous 
% submission as mentioned above.
% 
% To speed things up:
% Replace "inpolygon" function by Bruno Lunog's faster implementation:
% "2D polygon interior detection" :
% http://www.mathworks.com/matlabcentral/fileexchange/27840-2d-polygon-inte
% rior-detection
% Copyright (c) 2011, Tolga Birdal <http://www.tbirdal.me>

warning('off','all');
% make a voronoi diagram
[vx,vy]=voronoi(x,y);

% find voronoi nodes inside the polygon [x,y]
Vx=vx(:);
Vy=vy(:);
% Here, you could also use a faster version of inpolygon
IN=inpolygon(Vx,Vy, x,y);
ind=find(IN==1);
Vx=Vx(ind);
Vy=Vy(ind);

% maximize the distance of each voronoi node to the closest node on the
% polygon.
minDist=0;
minDistInd=-1;
for i=1:length(Vx)
    dx=(Vx(i)-x);
    dy=(Vy(i)-y);
    r=min(dx.*dx+dy.*dy);
    if (r>minDist)
        minDist=r;
        minDistInd=i;
    end
end

% take the center and radius
if minDistInd < 0
    cx = NaN;
    cy = NaN;
else
    cx=Vx(minDistInd);
    cy=Vy(minDistInd);
end
r=sqrt(minDist);

warning('on','all');
end

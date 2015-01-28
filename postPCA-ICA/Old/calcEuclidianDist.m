function euclideanDistance = calcEuclidianDist(point1, point2) 
%calcEuclidianDist.m Calculates euclidian distance in 3d space

%add third dimension if necessary
if length(point1) < 3 && length(point1) > 1
    point1(3) = 1;
end

if length(point2) < 3 && length(point2) > 1
    point2(3) = 1;
end

%check if everything is nan
if all(isnan(point1)) || all(isnan(point2))
    euclideanDistance = NaN;
    return;
end

%calculate distance
% euclideanDistance = sqrt(nansum((point2 - point1).^2));
vecDiff = point2 - point1;
if isrow(vecDiff);vecDiff = vecDiff';end
euclideanDistance = sqrt(vecDiff'*vecDiff);
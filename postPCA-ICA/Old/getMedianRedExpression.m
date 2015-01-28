function [medianRedExpression,shuffleExpression] = getMedianRedExpression(seg,redImage,nShuffles)
%GETMEANREDEXPRESSION Finds mean red expression in each segment output by
%the ICA algorith
%
%INPUTS
%seg - nonOverlapping filtered segments in a m x n x nSeg array
%redImage - red projection image
%nShuffles - number of shuffles for random expression
%
%OUTPUTS
%meanRedExpression - 1 x nSeg array of mean expression
%shuffleExpression - nShuffles x nSeg array of shuffle expression
%
%ASM 3/14

if nargin < 3 || isempty(nShuffles)
    nShuffles = 100;
end

%get nSeg
nSeg = size(seg,3);

%repmat redImage
redImage = repmat(redImage,1,1,nSeg);

%get real red expression
medianRedExpression = subsetRedExpression(nSeg,seg,redImage);

%perform 100 shuffles to get random expression
shuffleExpression = zeros(nShuffles,nSeg);
for i = 1:nShuffles
    
    %get random shifts
    horizontalShift = randi([0 size(redImage,2)]);
    verticalShift = randi([0 size(redImage,1)]);
    
    %perform shift
    shuffleSeg = circshift(seg,[verticalShift horizontalShift 0]);
    
    %get expression
    shuffleExpression(i,:) = subsetRedExpression(nSeg,shuffleSeg,redImage);

end
end

function redExp = subsetRedExpression(nSeg,seg,redImage)
%reshape into nPixels x nSeg
reshapeRed = reshape(redImage,size(redImage,1)*size(redImage,2),nSeg);
reshapeSeg = reshape(seg,size(seg,1)*size(seg,2),nSeg);

%multiply
redOverlap = reshapeRed.*reshapeSeg;

%set 0 vals to nan
redOverlap(redOverlap==0) = nan;

%take mean of each segment
redExp = nanmean(redOverlap);
end

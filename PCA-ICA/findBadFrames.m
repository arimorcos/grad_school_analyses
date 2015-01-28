function [badFrames] = findBadFrames(movie,corrThresh,downsampleFac)
%findBadFrames.m Function to look for frames with odd rotations which could
%interfere with PCA/ICA
%
%INPUTS
%movie - m x n x nFrames movie or fileName of movie
%corrThresh - minimum correlation threshold
%downsampleFac - factor by which to downsample to increase speed
%
%OUTPUTS
%badFrames - array containing indices of bad frames (frames with
%correlation to reference frame below corrThresh)
%
%ASM 10/13

%check if movie is movie or filename
if ischar(movie)
    movie = loadtiffAM(movie);
end

%downsample movie for faster processing
movie = imresize(movie,downsampleFac);

%get reference frame
refFrameInd = findRefFrame(movie);

%compare each frame 
corr = zeros(1,size(movie,3));
for i = 1:size(movie,3) %for each frame
    
    corr(i) = corr2(movie(:,:,refFrameInd),movie(:,:,i));
    
end

%find corr below thresh
badFrames = find(corr < corrThresh);
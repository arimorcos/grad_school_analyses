
%get imSub
imSub = getTrials(dataCell,'imaging.imData == 1');

%bin if necessary
if ~isfield(imSub{1}.imaging,'binnedDFFTraces')
    imSub = binFramesByYPos(imSub,15);
end

%left/right sub
leftSub = getTrials(imSub,'maze.crutchTrial==0;result.correct==1;maze.numLeft==0,6;result.leftTurn==1');
rightSub = getTrials(imSub,'maze.crutchTrial==0;result.correct==1;maze.numLeft==0,6;result.leftTurn==0');

%find lower one and crop
if length(leftSub) < length(rightSub)
    rightSub = rightSub(1:length(leftSub));
elseif length(leftSub) > length(rightSub)
    leftSub = leftSub(1:length(rightSub));
end

%get traces
leftTraces = catBinnedTraces(leftSub);
rightTraces = catBinnedTraces(rightSub);

%permute
leftTraces = permute(leftTraces,[3 1 4 2]);
rightTraces = permute(rightTraces,[3 1 4 2]);

%all traces
allTraces = cat(3,leftTraces,rightTraces);

%get classifier out
acc = classify_trajectory(allTraces);

%calculate accuracy
accuracy = zeros(1,size(acc,3));
for i = 1:size(acc,3) %for each plane
    for j = 1:size(acc,2) %for each trial type
        nCorr(i,j) = sum(acc(:,j,i) == j);
    end
    totalCorr = sum(nCorr(i,:));
    totalPoss = size(acc,1)*size(acc,2);
    accuracy(i) = 100*totalCorr/totalPoss;
end
dFFTraces = dataCell{1}.imaging.completeDFFTrace;
dGRTraces = dataCell{1}.imaging.completeDGRTrace;

%thresh
nSTD = 2.5;
minFrames = 8;
dFFThresh = thresholdCompleteTrace(dFFTraces,nSTD,minFrames);
dGRThresh = thresholdCompleteTrace(dGRTraces,nSTD,minFrames);

% %eliminate cells with fewer than 0.2 transients per minute
% frameRate = 5.67;
% transThresh = 0.2;
% nTransPerMin = getNTransPerMin(dFFThresh,frameRate);
% for i = 1:length(nTransPerMin)
%     dFFThresh{i}(nTransPerMin{i} < transThresh,:) = [];
% end
% 
% %eliminate non task mod cells
% for i = 1:length(nTransPerMin)
%     taskModCells = filterTaskMod(dFFThresh{i});
%     dFFThresh{i} = dFFThresh{i}(taskModCells,:);
% end
% 
% %filter
% triFilter = [0.25 0.5 0.25];
% dFFFilterThresh = cellfun(@(x) filter(triFilter,1,x),dFFThresh,'UniformOutput',false);

%copy back
dataCell = standaloneCopyDFFToDataCell(dataCell,dFFThresh,dGRThresh);

%bin 
if ~isfield(dataCell{1}.imaging,'binnedDFFTraces')
    dataCell = binFramesByYPos(dataCell,5);
end

%extract imaging trials
imTrials = getTrials(dataCell,'imaging.imData==1;maze.crutchTrial==0');
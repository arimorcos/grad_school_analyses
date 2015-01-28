function model = glmFixedTask(dataCell,varargin)
%glmFixedTask.m Fits a generalized linear model to the fixed task
%
%INPUTS
%dataCell - dataCell containing integration and imaging information
%
%VARIABLE INPUTS
%neuronInd - neuron to fit glm to 
%segRanges - segment ranges
%
%OUTPUTS
%
%
%ASM 11/14

%%%%%%%%%%%%%% PROCESS VARARGIN %%%%%%%%%%%%%%%%%%%%%%%%%%%

%initialize varargin
neuronInd = 1;
segRanges = 0:80:480;
onlySegmentPeriod = false;

%process varargin
if nargin > 1 || ~isempty(varargin)
    if isodd(length(varargin))
        error('Must provide a name and value for each argument');
    end
    for argInd = 1:2:length(varargin) %for each argument
        switch lower(varargin{argInd})
            case 'neuronind'
                neuronInd = varargin{argInd+1};
            case 'segranges'
                segRanges = varargin{argInd+1};
            case 'onlysegmentperiod'
                onlySegmentPeriod = varargin{argInd+1};
        end
    end
end

%%%%%%%%%%%%%%% CREATE FILTERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%subset to imaging trials
imTrials = getTrials(dataCell,'imaging.imData==1');

%get neuronal trace
traces = cell2mat(cellfun(@(x) x.imaging.dFFTraces{1},imTrials,'UniformOutput',false));

%get mazePatterns
mazePatterns = getMazePatterns(imTrials);
netEv = getMazePatterns(imTrials);
currCat = netEv;
currCat(currCat > 0) = 2;
currCat(currCat < 0) = 0;
currCat(currCat == 0) = 1;

%get nTrials and nSeg
[nTrials,nSeg] = size(mazePatterns);

%subset neuronal trace
if ~isempty(neuronInd)
    neuronTrace = traces(neuronInd,:)';
end

%create table
inputTable = table(neuronTrace);

%Y Position
yPosition = cell2mat(cellfun(@(x) x.imaging.dataFrames{1}(3,:),imTrials,'UniformOutput',false))';
inputTable = [inputTable table(yPosition)]; %add to input table

%X Position
xPosition = cell2mat(cellfun(@(x) x.imaging.dataFrames{1}(2,:),imTrials,'UniformOutput',false))';
inputTable = [inputTable table(xPosition)]; %add to input table

%X Velocity 
xVelocity = cell2mat(cellfun(@(x) x.imaging.dataFrames{1}(5,:),imTrials,'UniformOutput',false))';
inputTable = [inputTable table(xVelocity)]; %add to input table

%Y Velocity
yVelocity = cell2mat(cellfun(@(x) x.imaging.dataFrames{1}(6,:),imTrials,'UniformOutput',false))';
inputTable = [inputTable table(yVelocity)]; %add to input table

%Net Evidence
netEvidence = constructSegmentVector(imTrials,segRanges,@getNetEvidence);
inputTable = [inputTable table(netEvidence)];

%Number of Left Segments
numLeft = constructSegmentVector(imTrials,segRanges,@getNumLeft);
inputTable = [inputTable table(numLeft)];

%Number of Right Segments
numRight = constructSegmentVector(imTrials,segRanges,@getNumRight);
inputTable = [inputTable table(numRight)];

%Is a segment on?
segmentOn = constructSegmentVector(imTrials,0:80:480,ones(size(mazePatterns)));
inputTable = [inputTable table(segmentOn)];

%Is a segment on the left on?
leftSegmentOn = constructSegmentVector(imTrials,0:80:480,mazePatterns);
inputTable = [inputTable table(leftSegmentOn)];

%Is a segment on the right on?
rightSegmentOn = constructSegmentVector(imTrials,0:80:480,~mazePatterns);
inputTable = [inputTable table(rightSegmentOn)];

%What is the current category?
currentCategory = constructSegmentVector(imTrials,0:80:480,currCat);
inputTable = [inputTable table(currentCategory)];

%View Angle (theta)
viewAngle = cell2mat(cellfun(@(x) x.imaging.dataFrames{1}(4,:),imTrials,'UniformOutput',false))';
% viewAngle = shuffleArray(viewAngle);
inputTable = [inputTable table(viewAngle)]; %add to input table


%take only segment period
if onlySegmentPeriod
    inputTable = inputTable(yPosition >= segRanges(1) & yPosition < segRanges(end),:);
end

%convert to matrices 
responseVar = inputTable{:,'neuronTrace'};
predictorVar = inputTable{:,~ismember(inputTable.Properties.VariableNames,'neuronTrace')};
predictorVariableNames = inputTable.Properties.VariableNames(...
    ~ismember(inputTable.Properties.VariableNames,'neuronTrace'));

%%%%%%%%%%%%%%%%%%%%%%%%% FIT THE GLM %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
model = fitglm(inputTable,'responseVar','neuronTrace');
% model = stepwiseglm(inputTable,'linear','responseVar','neuronTrace');
% [B,fitInfo] = lassoglm(predictorVar,responseVar,'normal','NumLambda',25,'CV',10);
% model.B = B;
% model.fitInfo = fitInfo;
% model.varNames = predictorVariableNames;




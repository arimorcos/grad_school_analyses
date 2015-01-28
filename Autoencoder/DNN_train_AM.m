%% Variables
startPos = 400;
endPos = 600;

imSub = getTrials(dataCell,'imaging.imData==1');

%bin if necessary
if ~isfield(imSub{1}.imaging,'binnedDFFTraces')
    imSub = binFramesByYPos(imSub,10);
end

imSub = getTrials(imSub,'result.correct==1;maze.numLeft==0,6;maze.crutchTrial==0');

%get dFFTraces
dFFTraces = catBinnedTraces(imSub);
% dFFTraces = thresholdTraces(dataCell{1}.imaging.completeDFFTrace,imSub,2);

%only take sig Cells
dFFTraces = dFFTraces(sigCells,:,:);

%reshape dFFTraces
dFFReshape = reshape(dFFTraces,size(dFFTraces,1),numel(dFFTraces)/size(dFFTraces,1));

binReshape = repmat(imSub{1}.imaging.yPosBins,1,size(dFFTraces,3));

%leftRightTrials
leftTrialIDs = findTrials(imSub,'result.leftTurn==1')';
leftRightTrials = repmat(leftTrialIDs,length(imSub{1}.imaging.yPosBins),1); 
leftRightTrials = reshape(leftRightTrials,numel(leftRightTrials),1);

%crop out values below 0
eraseBinInd = sum(isnan(dFFReshape)) > 0;
binReshape(eraseBinInd) = [];
dFFReshape(:,eraseBinInd) = [];

%normalize - divide by sqrt(std)
dFFSTD = sqrt(nanstd(dFFReshape,0,2));
dFFReshape = dFFReshape./repmat(dFFSTD,1,size(dFFReshape,2));

%normalize by mean std
meanSTD = mean(nanstd(dFFReshape,0,2));
dFFReshape = dFFReshape./meanSTD;


runName = sprintf('Pos %d-%d delay (11iter w0_02 autosize)',startPos,endPos);

ind = binReshape >= startPos & binReshape < endPos;

alldata = dFFReshape(:,ind); % neuronal data
leftRightTrials = leftRightTrials(ind);

tPrediction = 0; 
trainIND = 1:size(alldata,2)-tPrediction; %all indices to train on 
testIND = trainIND(randperm(size(alldata,2)-tPrediction,round(size(alldata,2)/10))); %random subset of indices to test
weightCost = 1/20; % lower value means more curvature allowance ... good values 1/10000 - 1/25
maxEpoch = 1000; %number of training iterations
numChunks = 4; %data divided into chunks
numChunks_test = 1; %number of chunks in the test (1 - no chunks)
eraseIND = randperm(length(trainIND),mod(length(trainIND),numChunks)); %make it divisble by nChunks
trainIND(eraseIND)=[]; %erase those indices

%first normalize by dividing each neuron by sqrt(std), then take mean of
%each neurons std and divide all neurons by mean(std)

%% Format
seed = 1234;
randn('state', seed );
rand('twister', seed+1 );
resumeFile = [];
paramsp = [];
Win = [];
bin = [];
mattype = 'gn';
decay = 0.95;
jacket = 0;
hybridmode = 1;
rms = 0;
errtype = 'L2';

indata = alldata(:,trainIND);
outdata = alldata(:,trainIND + tPrediction); %offsets for temporal predition
intest = alldata(:,testIND);
outtest = alldata(:,testIND + tPrediction);
dataPerm = randperm(size(indata,2)); %shuffle indices to rearrange data
testPerm = randperm(size(intest,2));
indata = indata(:,dataPerm); %actually rearrange data
outdata = outdata(:,dataPerm); 
intest = intest(:,testPerm);
outtest = outtest(:,testPerm);

%% Layer Settings
layersizes = [50 25 2 25 50]; %nNeurons in each layer. Might need to add extra layers or change the pattern of layers
layertypes = {'tanh', 'tanh', 'linear', 'tanh','tanh', 'linear'}; %don't give type for input, but do for output
lsizeOUT = [size(alldata,1) layersizes size(alldata,1)];
ltypeOUT = layertypes;
ltypeOUT{find(layersizes == min(layersizes))} = 'linearSTORE';

runDesc = ['seed = ' num2str(seed) ', Using a temporal prediction of +' num2str(tPrediction)];

%% Train Net
nnet_train_2( runName, runDesc, paramsp, Win, bin, resumeFile, maxEpoch, indata, outdata, numChunks, intest, outtest, numChunks_test, layersizes, layertypes, mattype, rms, errtype, hybridmode, weightCost, decay, jacket);

%% Load
load(sprintf('%s_nnet_running',runName))
[W,b]=unpackPARAMS(paramsp,lsizeOUT); %converts to weights (W) and biases (b)
[y,l]=calcActivations(dFFReshape(:,ind),W,b,ltypeOUT); %computes predicted outputs, y, and linear code, l
sum(var(alldata,[],2)),
sum(var(alldata-y,[],2)), %should eliminate 3/4 of variance
sum(var(alldata-y,[],2))/sum(var(alldata,[],2))

%% plot
figure;
gscatter(l(1,:),l(2,:),leftRightTrials);

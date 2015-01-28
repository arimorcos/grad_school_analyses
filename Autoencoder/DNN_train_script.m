%% Variables
startPos = 200;
endPos = 300;
%runName = sprintf('Pos %d-%d (11iter w0_02 autosize)',startPos,endPos);
%ind = find(mod(datacat(7,:),1)==0 & datacat(3,:)>startPos & datacat(3,:)<endPos);
runName = sprintf('Pos %d-%d delay (11iter w0_02 autosize)',startPos,endPos);
ind = find(datacat(10,:)==0 & mod(datacat(7,:),1)==0 & datacat(3,:)>startPos & datacat(3,:)<endPos);
bData = datacat(:,ind);
alldata = dFilt(:,ind);
tPrediction = 0;
trainIND = 1:size(alldata,2)-tPrediction;
testIND = trainIND(randperm(size(alldata,2)-tPrediction,round(size(alldata,2)/10)));
weightcost = 1/50;
maxepoch = 300;
numchunks = 4;
numchunks_test = 1;
eraseIND = randperm(length(trainIND),mod(length(trainIND),numchunks));
trainIND(eraseIND)=[];

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
outdata = alldata(:,trainIND + tPrediction);
intest = alldata(:,testIND);
outtest = alldata(:,testIND + tPrediction);
dataPerm = randperm(size(indata,2));
testPerm = randperm(size(intest,2));
indata = indata(:,dataPerm);
outdata = outdata(:,dataPerm);
intest = intest(:,testPerm);
outtest = outtest(:,testPerm);

%% Layer Settings
layersizes = [size(indata,1) round(size(indata,1)/2) round(size(indata,1)/4)...
    2 round(size(indata,1)/4) round(size(indata,1)/2) size(indata,1)];
layertypes = {'tanh', 'tanh', 'tanh', 'linear', 'tanh','tanh', 'tanh', 'linear'};
lsizeOUT = [size(alldata,1) layersizes size(alldata,1)];
ltypeOUT = layertypes;
ltypeOUT{find(layersizes == min(layersizes))} = 'linearSTORE';

runDesc = ['seed = ' num2str(seed) ', Using a temporal prediction of +' num2str(tPrediction)];

%% Train Net
nnet_train_2( runName, runDesc, paramsp, Win, bin, resumeFile, maxepoch, indata, outdata, numchunks, intest, outtest, numchunks_test, layersizes, layertypes, mattype, rms, errtype, hybridmode, weightcost, decay, jacket);

%% Load
load(sprintf('%s_nnet_running',runName))
[W,b]=unpackPARAMS(paramsp,lsizeOUT);
[y,l]=calcActivations(dFilt(:,ind),W,b,ltypeOUT);
sum(var(alldata,[],2)),
sum(var(alldata-y,[],2)),

col(1,:) = [0 .5 1];
col(2,:) = [0 1 .5];
col(3,:) = [1 .75 0];
col(4,:) = [1 0 0];

% Find trials where mouse traverses stem length and get index/performance
mazeTime=[];tMat=[];useTrials=[];trialCond=[];continuity=[];reward=[];
for trial = min(bData(11,:)):max(bData(11,:))
    trialTimes = bData(11,:) == trial;
    
    if sum(trialTimes)>0
        trialData = bData(:,trialTimes);
        [sPos,sI] = min(trialData(3,:));
        [ePos,eI] = max(trialData(3,:));
    else
        sPos = nan;
        ePos = nan;
    end
    
    if sPos < startPos+20 & ePos > endPos-20
        tMat(trial) = find(trialTimes,1,'first')-1;
        useTrials(end+1) = trial;
        mazeTime(trial,1:ceil(sPos)-startPos) = sI;
        for p=(ceil(sPos):endPos) - startPos
            mazeTime(trial,p) = find(trialData(3,:)<(p+startPos),1,'last');
        end
    trialCond(trial) = unique(trialData(7,:));
    continuity(trial) = unique(trialData(10,:));
    reward(trial) = sum(datacat(8,datacat(11,:)==trial)) > 0;
    end
end

%% Plots

close all,
startPlot=startPos+00;
endPlot=endPos-00;
plotInd = find(bData(3,:)>startPlot & bData(3,:)<endPlot);
figure,scatter(l(1,plotInd),l(2,plotInd),25,bData(3,plotInd),'filled'),
figure,hold on,
for t=useTrials
    plotInd = tMat(t) + (mazeTime(t,startPlot-startPos+1) : mazeTime(t,endPlot-startPos));
    plot(l(1,plotInd),l(2,plotInd),'linewidth',1,'color',col(trialCond(t),:),'linestyle','--'),
    %plot(l(1,plotInd),l(2,plotInd),'.','markersize',6,'color',col(trialCond(t),:)),
    for i = find(mod(0:length(plotInd)-1,5)==0)
        if continuity(t)==0
            plot(l(1,plotInd(i)),l(2,plotInd(i)),'.','markersize',25,'color',col(trialCond(t),:)),
        elseif continuity(t)==1
            plot(l(1,plotInd(i)),l(2,plotInd(i)),'*','markersize',15,'linewidth',2,'color',col(trialCond(t),:)),
        end
        
        if reward(t) == 0
            plot(l(1,plotInd(i)),l(2,plotInd(i)),'.','markersize',15,'color',[0 0 0]),
        end
        
     end
end

% figure, hold on
% for i=plotInd
%     if bData(10,i) == 0
%         plot(l(1,i),l(2,i),'.','markersize',6,'color',col(bData(7,i),:))
%     elseif bData(10,i) == 1
%         plot(l(1,i),l(2,i),'+','markersize',6,'color',col(bData(7,i),:)) 
%     end
% end

% %% Prepare Movie
% 
% figure,hold on,
% for t=useTrials
%     plotInd = tMat(t) + (mazeTime(t,1) : mazeTime(t,end));
%     plot(l(1,plotInd),l(2,plotInd),'linewidth',2,'color',col(trialCond(t),:))
% end
% axis tight,hold off,
% ax=xlim;
% ay=ylim;
% textPos = input('Text position as [x y] vector :  ');
% %% Make Movie
% 
% stateMov=uint8([]);
% for i = (startPos+1:endPos) - startPos
%     for t=useTrials
%     plotInd = tMat(t)+mazeTime(t,max(i-5,1)) : tMat(t) + mazeTime(t,i);
%     plot(l(1,plotInd(end)),l(2,plotInd(end)),'color',col(trialCond(t),:)),
%     hold on,
%         if continuity(t) == 1
%             plot(l(1,plotInd(end)),l(2,plotInd(end)),'*','markersize',15,'color',col(trialCond(t),:)),
%         elseif continuity(t) == 0
%             plot(l(1,plotInd(end)),l(2,plotInd(end)),'.','markersize',30,'color',col(trialCond(t),:))
%         end
%         
%         if reward(t) == 0
%             plot(l(1,plotInd(end)),l(2,plotInd(end)),'.','markersize',20,'color',[1 1 1]),
%         end
%         
%     end
%     xlim(ax),ylim(ay)
%     set(gca,'color',[0 0 0]),
%     tHandle = text(textPos(1),textPos(2),sprintf('t = %d',i+startPos));
%     set(tHandle,'BackgroundColor',[1 1 1])
%     set(tHandle,'FontSize',16)
%     hold off
%     drawnow,
%     m=getframe;
%     stateMov(:,:,:,i) = m.cdata;
%     delete(tHandle),
% end
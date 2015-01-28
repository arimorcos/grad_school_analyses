%%function integrationAxisMante(dataCell,binRange)
%integrationAxisMante.m Creates integration axis as described in Mante et
%al. 2013. 
%
%INPUTS
%dataCell - dataCell containing binned imaging data
%binRange - 1 x 2 vector of start and stop bins to include in averaging for
%   axis creation
%
%OUTPUTS
%
%ASM 5/14

%% parameters
nPCs = 12;
binRange = [51 60];

%%
%define segRanges
segRanges = [1:10:51; 10:10:60]'; %in bins

%extract traces
traces = catBinnedTraces(dataCell);

%z-score
zTraces = zScoreTraces(traces);

%extract area within bin range
zTraces = zTraces(:,binRange(1):binRange(2),:);

%get cumEv
mazePatterns = getMazePatterns(dataCell); %get maze patterns
mazePatterns(mazePatterns == 0) = -1; %set 0 values to -1
cumEvAllSeg = cumsum(mazePatterns,2); %take cumsum
currSeg = find(segRanges(:,1) <= binRange(1),1,'last'); %find current segment
netEv = cumEvAllSeg(:,currSeg);

%get matrix size
[nNeurons,nBins,nTrials] = size(zTraces);

%% sort by conditions and reshape z-scored traces to create a matrix of size nUnits x (nCond*nBins)
%get unique combinations
uniqueNetEv = unique(netEv); %get unique net evidence options
uniqueCurrSeg = [-1 1]; %can only be left or right
uniqueChoice = [-1 1]; %can only be left or right
conditions = allcomb(uniqueNetEv,uniqueCurrSeg,uniqueChoice); %find all combinations
nCond = size(conditions,1); %get number of combinations
tempCond = cell(1,nCond); %initialize temporary array of combinations

%loop through each trial and figure out which combination it matches
for trialInd = 1:nTrials

    %find matching condition
    leftTurn = dataCell{trialInd}.result.leftTurn;
    if leftTurn==0,leftTurn = -1;end;
    [~,condInd] = ismember([netEv(trialInd) mazePatterns(trialInd,currSeg) leftTurn],...
        conditions,'rows');
    
    %store data
    tempCond{condInd} = zTraces(:,:,trialInd);
end

%concatenate
condTraces = cat(2,tempCond{:});
condTracesMat = cat(3,tempCond{:});

%ignore empty conditions
filtCond = conditions(~cellfun(@isempty,tempCond),:);
nFiltCond = size(filtCond,1);

%% perform PCA on this space
covMat = cov(condTraces'); %get covariance matrix
[PCs,eVal] = eigs(covMat,nPCs); %find eigenvectors (PCs)

%create denoising matrix
deNoiseMat = zeros(nNeurons);
for pcInd = 1:nPCs
    deNoiseMat = deNoiseMat + PCs(:,pcInd)*PCs(:,pcInd)';
end
% deNoiseMat = PCs*PCs';

%multiply denoising matrix by original data
condTracesDenoise = deNoiseMat*condTraces;

%% regression
% create regression equation of the form:
%r_i,t(k) = B_i,t(1)*choice(k) + B_i,t(2)*currSeg(k) + B_i,t(3)*netEv(k) +
%   B_i,t(4)

%create regression matrix F of size nCoef x nTrials x nNeurons
nCoef = 4;
F_i = ones(nCoef,nTrials);
F_i(1,:) = getCellVals(dataCell,'result.leftTurn'); %mouse choice (result.leftTurn)
F_i(1,F_i(1,:) == 0) = -1; %replace zero values with -1
F_i(2,:) = mazePatterns(:,currSeg)'; %current segment identity (left or right)
F_i(3,:) = netEv'; %net evidence

%estimate regression coefficients
%B_i,t = ((F_i*F_i')^-1) * F_i*r_i,t
regMat = inv(F_i*F_i')*F_i; %constant for all neurons
B_it = zeros(nNeurons,nBins,nCoef); %initialize array
for neuronInd = 1:nNeurons %loop through each neuron
    for binInd = 1:nBins %at each bin
        B_it(neuronInd,binInd,:) = regMat*squeeze(traces(neuronInd,binInd,:)); %coefficients for neuron i at time t = regMat*the current rate of neuron
    end
end

%% regresion subspace

%reshape B_it to B_vt
B_vt = permute(B_it,[3 2 1]);

%project regression vectors into PC space
B_vtPCA = zeros(size(B_vt));
for binInd = 1:nBins
    for coefInd = 1:nCoef
        
        B_vtPCA(coefInd,binInd,:) = deNoiseMat*squeeze(B_vt(coefInd,binInd,:));
    end
end

%find time of maximum norm for each variable
normVals = zeros(nCoef,nBins);
for coefInd = 1:nCoef %for each coefficient
    for binInd = 1:nBins %for each bin
        normVals(coefInd,binInd) = norm(squeeze(B_vtPCA(coefInd,binInd,:)));
    end
end
[~,normMaxInd] = max(normVals,[],2);

%extract values corresponding to max norm
B_vtMaxPCA = zeros(nCoef,1,nNeurons);
for coefInd = 1:nCoef
    B_vtMaxPCA(coefInd,1,:) = B_vtPCA(coefInd,normMaxInd(coefInd),:);
end
    
%% orthogonalize different variable vectors

%create Bmax
Bmax = permute(B_vtMaxPCA,[3 1 2]);

%qr decomposition
[Q,R] = qr(Bmax);

%extract orthogonalized regression vectors 
B_vorthog = Q(:,1:nCoef);

%% project responses onto orthogonal axes

projResp = zeros(nCoef,nBins,nFiltCond);
for condInd = 1:nFiltCond
    projResp(:,:,condInd) = B_vorthog'*condTracesMat(:,:,condInd);
end

%% extract values
%net evidence
netEvResp = squeeze(projResp(3,:,:)); %netEvResp - nBins x nCond
meanNetEvResp = mean(netEvResp); %mean for each condition

%current segment identity
currSegResp = squeeze(projResp(2,:,:)); %netEvResp - nBins x nCond
meanCurrSegResp = mean(currSegResp); %mean for each condition

%choice 
choiceResp = squeeze(projResp(1,:,:)); %netEvResp - nBins x nCond
meanChoiceResp = mean(choiceResp); %mean for each condition

%% plot
figure;
subplot(2,2,1);
gscatter(meanNetEvResp,ones(1,nFiltCond),filtCond(:,1),[],[],50);
set(gca,'FontSize',15)
title('Net Evidence');

subplot(2,2,2);
gscatter(meanCurrSegResp,ones(1,nFiltCond),filtCond(:,2),[],[],50);
set(gca,'FontSize',15)
title('Segment Identity');

subplot(2,2,3);
gscatter(meanChoiceResp,ones(1,nFiltCond),filtCond(:,3),[],[],50);
set(gca,'FontSize',15)
title('Choice');




    
    
    

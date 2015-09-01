function [accuracy,guess,classes,probEst] = getSVMAccuracy(traces,realClass,varargin)
%getSVMAccuracy Trains a cross-validated svm
%
%INPUTS
%traces - nNeurons x nBins x nTrials array of traces
%realClass - 1 x nTrials array of class for each trial. Each value should
%   be an integer
%
%OPTIONAL INPUTS
%shouldntCompareSame - provide separate class which shouldn't be compared
%   intra
%cParam - parameter for amount of regularization
%gamma - for RBF kernel, controls spread of gaussian. Default is
%   1/nFeatures
%kernel - kernel type. Default is 'rbf'
%svmType - svm type. Options are 'SVC,' 'e-SVR,' 'nu-SVR'
%epsilon - epsilon for epsilon SVR
%nu - nu for nu-SVR
%kFold - number of cross validations. Default is 10
%verbose - should output verbose arguments
%trainFrac - fraction of data to train on if not cross validating. Default
%   is 0.5.
%shouldScale - whether or not to scale
%leaveOneOut - perform leave one out training
%
%OUTPUTS
%accuracy - 1 x nBins array of classifier accuracy as a percentage
%guess - nTrials x nBins array of classifier guesses
%classs - 1 x nClasses array of classes
%
%ASM 12/14

shouldntCompareSame = false;
sameClass = [];
cParam = 2;
gamma = 0.04;
kernel = 'rbf';
svmType = 'SVC';
nu = 0.5;
epsilon = 0.1;
kFold = 1;
quietMode = true;
trainFrac = 0.5;
trainInd = [];
shouldScale = true;
leaveOneOut = false;

%process varargin
if nargin > 1 || ~isempty(varargin)
    if isodd(length(varargin))
        error('Must provide a name and value for each argument');
    end
    for argInd = 1:2:length(varargin) %for each argument
        switch lower(varargin{argInd})
            case 'dontcomparesame'
                shouldntCompareSame = true;
                sameClass = varargin{argInd+1};
            case 'cParam'
                cParam = varargin{argInd+1};
            case 'gamma'
                gamma = varargin{argInd+1};
            case 'kernel'
                kernel = varargin{argInd+1};
            case 'svmtype'
                svmType = varargin{argInd+1};
            case 'nu'
                nu = varargin{argInd+1};
            case 'epsilon'
                epsilon = varargin{argInd+1};
            case 'kfold'
                kFold = varargin{argInd+1};
            case 'trainind'
                trainInd = varargin{argInd+1};
            case 'verbose'
                quietMode = ~varargin{argInd+1};
            case 'trainfrac'
                trainFrac = varargin{argInd+1};
            case 'shouldscale'
                shouldScale = varargin{argInd+1};
            case 'leaveoneout'
                leaveOneOut = varargin{argInd+1};
        end
    end
end

%%%%%%%%%%%%%%%%%%% specify SVM options %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%kernel
switch kernel
    case 'linear'
        kernel_type = 0;
    case 'polynomial'
        kernel_type = 1;
    case 'rbf'
        kernel_type = 2;
    case 'sigmoid'
        kernel_type = 3;
    otherwise
        error('Kernel %s not recognized',kernel);
end

%svm type
switch svmType
    case 'SVC'
        svmType = 0;
    case 'e-SVR'
        svmType = 3;
    case 'nu-SVR'
        svmType = 4;
    otherwise
        error('SVM Type %s not recognized',svmType);
end

%leaveOneOut
if leaveOneOut
    kFold = 0;
end

%check realClass
if sum(size(realClass) > 1) > 1 %if more than one dimensional
    error('realClass must be a one-dimensional vector');
end
if size(realClass,1) < size(realClass,2) %if row vector
    realClass = realClass';
end
classes = unique(realClass);
%%%%%%%%%%%%%%%%% CREATE SVM %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%generate options string
svmOptions = sprintf('-s %d -t %d -g %1.10f -c %1.10f -n %1.10f -e %1.10f -b 1',...
    svmType, kernel_type, gamma, cParam, nu, epsilon);

%add quiet mode if true
if quietMode
    svmOptions = sprintf('%s -q',svmOptions);
end

%get nBins
[~, nBins, nTrials] = size(traces);

%initialize
accuracy = nan(nBins,1);
if kFold > 2
    guess = [];
    probEst = [];
else
    guess = nan(nTrials - round(nTrials*trainFrac), nBins);
    probEst = nan(nTrials - round(nTrials*trainFrac), nBins);
end

if svmType ~= 0
    nTest = floor(nTrials*(1-trainFrac));
    guess = nan(1,nBins);
    accuracy = nan(nTest,nBins);
    classes = nan(nTest,nBins);
    probEst = nan(1,nBins);
end

%convert realClass to double
realClass = double(realClass);

%loop through each bin
for binInd = 1:nBins
    
    %get binTraces
    if size(traces,1) == 1
        binTraces = squeeze(traces(:,binInd,:));
    else
        binTraces = squeeze(traces(:,binInd,:))';
    end
    
    %scale data
    if shouldScale
        binTraces = scaleSVMData(binTraces);
        binTraces = binTraces(:,~any(isnan(binTraces))); %remove nans
    end
    
    %train svm
    if kFold > 2 %if cross validation
        
        %add cross validation flag
        tempSvmOptions = sprintf('%s -v %d', svmOptions, kFold);
        
        accuracy(binInd) = svmtrain_libsvm(realClass, binTraces, tempSvmOptions);
    elseif leaveOneOut
        
        %loop through every trial
        for testInd = 1:nTrials
            %get trainInd
            trainInd = setdiff(1:nTrials,testInd);
            
            %create training and testing subsets
            trainSet = binTraces(trainInd,:);
            testSet = binTraces(testInd,:);
            trainClass = realClass(trainInd);
            testClass = realClass(testInd);
            
            %train model
            svmModel = svmtrain_libsvm(trainClass, trainSet, svmOptions);
            
            %test model
            if quietMode
                svmPredictOptions = '-q';
            else
                svmPredictOptions = '';
            end
            [guess(testInd,binInd),~,probEst(testInd,binInd)] = ...
                svmpredict_libsvm(testClass, testSet, svmModel, svmPredictOptions);
        end
        
        %get accuracy
        accuracy(binInd) = 100*sum(realClass == guess(:,binInd))/nTrials;
    else
        if isempty(trainInd)
            %get training and testing ind
            trainInd = randsample(nTrials,round(nTrials*trainFrac));
        end
        testInd = setdiff(1:nTrials,trainInd);
        
        %create training and testing subsets
        trainSet = binTraces(trainInd,:);
        testSet = binTraces(testInd,:);
        trainClass = realClass(trainInd);
        testClass = realClass(testInd);
        
        %train model
        svmModel = svmtrain_libsvm(trainClass, trainSet, svmOptions);
        
        %test model
        if quietMode
            svmPredictOptions = '-q';
        else
            svmPredictOptions = '';
        end
        
        if svmType == 0
            [guess(:,binInd),~,probEst(:,binInd)] = svmpredict_libsvm(testClass, testSet, svmModel, svmPredictOptions);
            accuracy(binInd) = 100*sum(guess(:,binInd) == testClass)/numel(testClass);
        else
            [accuracy(:,binInd),vals,~] = svmpredict_libsvm(testClass, testSet, svmModel, svmPredictOptions);
            guess(binInd) = vals(2); %mean squared error
            probEst(binInd) = vals(3); %R^2
            classes(:,binInd) = testClass;
        end
        
    end
    
end
end

function out = scaleSVMData(data)

out = (data - repmat(min(data,[],1),size(data,1),1))*spdiags(1./(max(data,[],1)-min(data,[],1))',0,size(data,2),size(data,2));
end


%%%%%%%%%%%%% access token
accessToken = '2c0eeb9f-34e5-46b9-8498-0d45ffa57d36';

%%%%%%%%%%%%% Create experiment name
currExpName = 'Optimize History SVM RBF Pooled Left';
currExpDate = datestr(now,'yymmdd-HH:MM:SS');
currExp = sprintf('%s %s',currExpName,currExpDate);

%%%%%%%%%%%%% set up parameters
parameters = {struct('name', 'C', 'type', 'float', 'min', 2^-10, 'max', 2^20, 'size', 1),...
              struct('name', 'gamma', 'type', 'float', 'min', 2^-20, 'max', 2^5, 'size', 1)};
          
outcome.name = 'Accuracy';

nIter = 1000;

%%%%%%%%%%%%% create whetlab object
scientist = whetlab(currExp, 'Optimize 1 seg back pooled classification using rbf svm',...
    parameters, outcome, true, accessToken);

%%%%%%%%%%%%% provide known vals
% job = struct('C',30000,'gamma',0.145);
% scientist.update(job,88.49);

%%%%%%%%%%%%%%%%%%%% optimize

for iterNum = 1:nIter
    
    %get suggestion
    job = scientist.suggest();
    
    %run job
    accuracyLeft = poolHistoryPatternsTriplets(imTrials,'separateLeftRight',true,...
        'c',job.C,'gamma',job.gamma,'nShuffles',0);
    accuracyLeft = accuracyLeft(2);
    
    %update 
    scientist.update(job,accuracyLeft); 
    
end


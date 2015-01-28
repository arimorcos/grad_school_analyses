%%%%%%%%%%%%% access token
accessToken = '2c0eeb9f-34e5-46b9-8498-0d45ffa57d36';

%%%%%%%%%%%%% Create experiment name
currExpName = 'Optimize History SVM RBF';
currExpDate = datestr(now,'yymmdd-HH:MM:SS');
currExp = sprintf('%s %s',currExpName,currExpDate);

%%%%%%%%%%%%% set up parameters
parameters = {struct('name', 'C', 'type', 'float', 'min', 2^-5, 'max', 2^15, 'size', 1),...
              struct('name', 'gamma', 'type', 'float', 'min', 2^-15, 'max', 2^3, 'size', 1)};
          
outcome.name = 'Accuracy';

nIter = 300;

%%%%%%%%%%%%% create whetlab object
scientist = whetlab(currExp, 'Optimize 1 seg back classification using rbf svm',...
    parameters, outcome, true, accessToken);

%%%%%%%%%%%%% provide known vals
job = struct('C',30000,'gamma',0.145);
scientist.update(job,88.49);

%%%%%%%%%%%%%%%%%%%% optimize

for iterNum = 1:nIter
    
    %get suggestion
    job = scientist.suggest();
    
    %run job
    accuracy = predictPrevSegIdSVM(imTrials,'whichSeg',1, 'c', job.C, ...
        'gamma', job.gamma);
    accuracy = accuracy(2);
    
    %update 
    scientist.update(job,accuracy); 
    
end


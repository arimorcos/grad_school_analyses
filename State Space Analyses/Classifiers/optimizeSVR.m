%%%%%%%%%%%%% access token
accessToken = '2c0eeb9f-34e5-46b9-8498-0d45ffa57d36';

%%%%%%%%%%%%% Create experiment name
currExpName = 'Optimize epsilon-SVR';
currExpDate = datestr(now,'yymmdd-HH:MM:SS');
currExp = sprintf('%s %s',currExpName,currExpDate);

%%%%%%%%%%%%% set up parameters
parameters = {struct('name', 'C', 'type', 'float', 'min', 2^-5, 'max', 2^15, 'size', 1),...
              struct('name', 'gamma', 'type', 'float', 'min', 2^-15, 'max', 2^3, 'size', 1),...
              struct('name', 'epsilon', 'type', 'float', 'min', 2^-15, 'max', 2^1, 'size', 1)};
          
outcome.name = 'Negative mean squared error';

nIter = 300;

%%%%%%%%%%%%% create whetlab object
scientist = whetlab(currExp, 'Optimize svr rbf svm',...
    parameters, outcome, true, accessToken);

%%%%%%%%%%%%%%%%%%%% optimize
%%
for iterNum = 1:nIter
    
    %get suggestion
    job = scientist.suggest();
    
    %run job
    mSE = getSVMAccuracy(seg6Traces, realClass, 'svmType', 'e-SVR',...
        'C', job.C, 'gamma', job.gamma, 'epsilon', job.epsilon);
    
    %update 
    scientist.update(job,-1*mSE); 
    
end


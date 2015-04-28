mouse = 'AM136'; date = '140820';
% mouse = 'AM131'; date = '140911';
% mouse = 'AM150'; date = '141128';
% mouse = 'AM150'; date = '141206';
% mouse = 'AM144'; date = '141203';
% mouse = 'AM142'; date = '141218';

switch computer
    case 'MACI64'
        filePath = sprintf('/Users/arimorcos/Data/Analyzed Data/Mice/%s_%s_processed.mat',mouse,date);
    case 'PCWIN64'
        filePath = sprintf('W:\\Mice\\%s_%s_processed.mat',mouse,date);
end
load(filePath);
leftTrials = getTrials(imTrials,'maze.leftTrial==1');
rightTrials = getTrials(imTrials,'maze.leftTrial==0');
trials60 = getTrials(imTrials,'maze.numLeft==0,6');
correctTrials = getTrials(imTrials,'result.correct==1');
errorTrials = getTrials(imTrials,'result.correct==0');
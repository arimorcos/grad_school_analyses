function loadProcessed(mouse,date)

if nargin < 2

% mouse = 'AM136'; date = '140820';
% mouse = 'AM131'; date = '140911';
% mouse = 'AM150'; date = '141128';
% mouse = 'AM150'; date = '141206';
mouse = 'AM144'; date = '141203';
% mouse = 'AM142'; date = '141218';
end

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
left60 = getTrials(imTrials,'maze.numLeft==6');
right60 = getTrials(imTrials,'maze.numLeft==0');
correctLeft60 = getTrials(imTrials,'result.correct==1;maze.numLeft==6');
correctRight60 = getTrials(imTrials,'maze.numLeft==0;result.correct==1');

assignin('base','mouse',mouse);
assignin('base','date',date);
assignin('base','imTrials',imTrials);
assignin('base','leftTrials',leftTrials);
assignin('base','trials60',trials60);
assignin('base','rightTrials',rightTrials);
assignin('base','correctTrials',correctTrials);
assignin('base','errorTrials',errorTrials);
assignin('base','left60',left60);
assignin('base','right60',right60);
assignin('base','correctLeft60',correctLeft60);
assignin('base','correctRight60',correctRight60);

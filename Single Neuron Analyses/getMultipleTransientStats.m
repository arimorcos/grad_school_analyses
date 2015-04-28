function stats = getMultipleTransientStats(mice,dates)
%
%
%
if nargin < 2
    dates = {'140820',...
        '141203',...
        '141218',...
        '141128'};
end
if nargin < 1
    mice = {'AM136',...
        'AM144',...
        'AM142',...
        'AM150'};
end

%get nMice
nMice = length(mice);

%initialize


for mouseInd = 1:nMice
    dispProgress('Loading mouse %d/%d',mouseInd,mouseInd,nMice);
%     switch computer
%         case 'MACI64'
%             filePath = sprintf('/Users/arimorcos/Data/Analyzed Data/Mice/%s_%s_processed.mat',...
%                 mice{mouseInd},dates{mouseInd});
%         case 'PCWIN64'
%             filePath = sprintf('W:\\Mice\\%s_%s_processed.mat',...
%                 mice{mouseInd},dates{mouseInd});
%     end
%     load(filePath,'imTrials');
    
    dataCell = loadBehaviorData(mice{mouseInd},dates{mouseInd});
    dataCell = thresholdDataCell(dataCell);
    imTrials = getTrials(dataCell,'imaging.imData==1;maze.crutchTrial==0');
    
    %get stats
    allStats(mouseInd) = getTransientStats(imTrials);
    
end

stats.meanNTransients = cat(1,allStats.meanNTransients);
stats.stdNTransients = cat(1,allStats.stdNTransients);
stats.meanTransLength = cat(2,allStats.meanTransLength);
stats.stdTransLEngth = cat(2,allStats.stdTransLEngth);
stats.meanFracLength = cat(1,allStats.meanFracLength);
stats.stdFracLength = cat(1,allStats.stdFracLength);


function allData = getAllMouseData(mice,dates)
%getAllMosueData.m Loadss all processed data from given mice
%
%INPUTS
%mice - cell array of mice
%dates - cell array of dates
%
%OUTPUTS
%allData - cell array of concatenated imTrials
%
%ASM 4/15

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
allData = {};

for mouseInd = 1:nMice
    dispProgress('Loading mouse %d/%d',mouseInd,mouseInd,nMice);
    switch computer
        case 'MACI64'
            filePath = sprintf('/Users/arimorcos/Data/Analyzed Data/Mice/%s_%s_processed.mat',...
                mice{mouseInd},dates{mouseInd});
        case 'PCWIN64'
            filePath = sprintf('W:\\Mice\\%s_%s_processed.mat',...
                mice{mouseInd},dates{mouseInd});
    end
    load(filePath,'imTrials');
    allData = cat(2,allData,imTrials);
    
end
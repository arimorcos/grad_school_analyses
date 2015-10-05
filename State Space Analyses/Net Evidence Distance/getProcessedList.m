function procList = getProcessedList()
%getProcessedList.m Gets list of processed datasets 
%
%ASM 6/15

switch computer
    case 'MACI64'
        filePath = '/Users/arimorcos/Data/Analyzed Data/Mice/oldDeconv_smooth10';
    case 'PCWIN64'
        filePath = 'W:\\Mice\\';
end

%get list of files 
fileList = dir2cell(filePath);
fileList = fileList(~cellfun(@isempty,regexpi(fileList,'AM.*_processed.mat')));

%get mouse and date
tempList = regexp(fileList,'(AM\d{3})_(\d{6})_processed.mat','tokens');
procList = cellfun(@(x) x{1},tempList,'uniformoutput',false);
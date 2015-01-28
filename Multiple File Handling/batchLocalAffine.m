function batchLocalAffine(rootFolder)

% if length(folderPaths) ~= length(fileStrings)
%     error('Different number of strings');
% end
% 
% % setpref('Internet','SMTP_Server','mail.google.com');
% % setpref('Internet','E_mail','arimorcos@gmail.com');
% 
% for i = 1:length(folderPaths) %for each file
%     try
%         fprintf('Trying %s\n',folderPaths{i});
%         localAffineMotionCorrect(folderPaths{i},fileStrings{i},true);
%         fprintf('Completed %s\n',folderPaths{i});
%     catch
%         % %         sendmail('arimorcos@gmail.com',sprintf('Error Reported file %d',i),...
%         % %             sprintf('Error Reported for folder path: %s    file path: %s',...
%         % %             folderPaths{i},fileStrings{i}));
%         fprintf('Error in %s\n',folderPaths{i});
%     end
%     
%     
% end
% sendmail('arimorcos@gmail.com','Batch motion correct job successful');

if nargin < 1 
    rootFolder = [];
end

fileStr = 'AM\d\d\d.*\d\d\d_\d\d\d.tif';
folderPaths = findUnprocessedImagingData(rootFolder);
exclude = {'W:\Resscan\AM131\140804'};

%exclude bad entries
folderPaths = folderPaths(~ismember(folderPaths,exclude));

while ~isempty(folderPaths)
    try
        fprintf('Trying %s\n',folderPaths{1});
        localAffineMotionCorrect(folderPaths{1},fileStr,true);
        fprintf('Completed %s\n',folderPaths{1});
    catch err
        if strcmpi(err.identifier,'localAffineMotionCorrect:DiskSpaceError') %if disk space error throw error and exit
            throw(err);
        end
        fprintf('Error in %s\n',folderPaths{1});
        getReport(err)
        exclude = cat(1,exclude,folderPaths(1));
        close all;
    end
    %get new folder path
    folderPaths = findUnprocessedImagingData(rootFolder);
    
    %exclude bad entries
    folderPaths = folderPaths(~ismember(folderPaths,exclude));
end
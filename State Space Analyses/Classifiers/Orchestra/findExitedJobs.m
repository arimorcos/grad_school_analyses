function findExitedJobs(folder)

%get list of files
fileList = dir2cell(folder);
fileList = fileList(3:end);

%loop through each file 
hasDisp = false;
for fileInd = 1:length(fileList)
   
    %read in entire file 
    text = fileread(fullfile(folder,fileList{fileInd}));
    
    if ~isempty(strfind(text,'Exited'))
        disp(fileList{fileInd});
        hasDisp = true;
    end
    
    
end

if ~hasDisp
    disp('No exited jobs found');
end
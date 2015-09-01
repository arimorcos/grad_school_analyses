%get list of files in folder 
[allNames, ~, ~, ~, isDirs] = dir2cell(cd);
files = allNames(~isDirs);

%match string 
matchFiles = files(~cellfun(@isempty,regexp(files,'AM\d{3}_\d{6}_netEvAddIn.mat')));

%get nFiles
nFiles = length(matchFiles);

%loop through 
for file = 1:nFiles
    
    dispProgress('Processing dataset %d/%d',file,file,nFiles);
    
    %load 
    load(matchFiles{file},'classifierOut');
    
    %get corrcoef by neruon 
    addInCorr = cat(1,0,cellfun(@getNetEvCorrCoef,classifierOut(2:end)));
    addInSlope = cat(1,0,cellfun(@getNetEvSlope,classifierOut(2:end)));
    
    %save 
    save(matchFiles{file},'addInCorr','addInSlope','-append');
    
end
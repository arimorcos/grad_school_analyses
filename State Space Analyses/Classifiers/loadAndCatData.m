function varargout = loadAndCatData(folder, match, fields)
%loadAndCatData.m Loads and concatenates variables from files matching the
%same string 
%
%INPUTS
%folder - path to folder to load from 
%match - regexp string 
%
%OUTPUTS
%variables stored in data
%
%ASM 3/15

% get list of files
fileList = dir2cell(folder);

%change to directory 
origDir = cd(folder);

%filter 
filtFile = fileList(~cellfun(@isempty,regexp(fileList,match)));

% loop through and load
for ind = 1:length(filtFile)
   
    %load data
    fileData = load(filtFile{ind});
    
    %get list of fields 
    fieldList = fieldnames(fileData);
    
    %initialize
    if ind == 1
        varargout = cell(length(fields) + 1);
        for i = 1:length(varargout)
            varargout{i} = cell(length(filtFile),1);
        end
    end
    
    %concatenate 
    varargout{1}{ind} = filtFile(ind);
    for fieldInd = 1:length(fields)
        if any(strcmpi(fields{fieldInd},fieldList))
            varargout{fieldInd+1}{ind} = fileData.(fields{fieldInd});
        else
            error('No matching field %s for file %s', fields{fieldInd},...
                filtFile{ind})
        end
    end
  
end

cd(origDir);
function [uniqueRows, uniqueCount] = count_unique_rows(in)
%count_unique_rows.m Counts unique number of rows 
%
%ASM 8/15

%et unique rows 
uniqueRows = unique(in,'rows');
nUnique = size(uniqueRows,1);

%initialize
uniqueCount = nan(nUnique,1);
for i = 1:nUnique
    uniqueCount(i) = sum(ismember(in,uniqueRows(i,:),'rows'));
end


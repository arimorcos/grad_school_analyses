function conds = generateEachPatternCond(dataCell)
%generateEachPatternCond.m Generates each and every pattern contained
%within the dataCell
%
%INPUTS
%dataCell - dataCell containing integration data
%
%OUTPUTS
%conds - 1 x nConds cell array containing conditions for every pattern
%
%ASM 11/14

%get all patterns
mazePatterns = getMazePatterns(dataCell);

%get all unique patterns
mazePatterns = unique(mazePatterns,'rows');

%put in proper format for dataCell filtering
conds = cellfun(@(x) ['[ ',x,' ]'],cellstr(num2str(mazePatterns)),'UniformOutput',false);

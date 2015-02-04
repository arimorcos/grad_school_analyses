function legString = convertTableToLegendString(inTable)
%convertTableToLegendString.m Converts each row of the table into a legend
%string of the format 'var1 = val1; var2 = val2'
%
%INPUTS
%inTable - table with named variables
%
%OUTPUTS
%legString - nRows x 1 cell array of legend strings
%
%ASM 1/15

%assert that input is a table
assert(istable(inTable),'Must provide a table');

%get nRows
nRows = size(inTable,1);

%create empty string 
legString = cell(nRows,1);

%get number of variables 
varNames = inTable.Properties.VariableNames;
nVars = length(varNames);

%loop through each row and create string
for rowInd = 1:nRows
    legString{rowInd} = '';
    for varInd = 1:nVars
        legString{rowInd} = [legString{rowInd}, ' ', varNames{varInd}, ' = ',...
            num2str(inTable{rowInd,varNames{varInd}}), ';'];
    end
    %remove last character (semicolon)
    legString{rowInd}(end) = [];
end


           
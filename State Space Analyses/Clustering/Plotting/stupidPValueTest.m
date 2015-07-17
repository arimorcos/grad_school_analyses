nRandom = 1e4;
nTest = 1000;


% generate 10,000 random values and sort
randValues = sort(rand(nRandom,1));

%generate 100 test values 
testValues = rand(nTest,1);

%get pValue for each 
fracGreater = nan(nTest,1);
for test = 1:nTest
    
    %get fraction greater than 
    tempVal = find(testValues(test) >= randValues, 1, 'last')/nRandom;
    if isempty(tempVal)
        fracGreater(test) = 0;
    else
        fracGreater(test) = tempVal;
    end
end

%histogram of distribution 
histogram(fracGreater,20);

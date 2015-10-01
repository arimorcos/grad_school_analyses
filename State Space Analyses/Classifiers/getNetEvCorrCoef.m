function [corrCoef,shuffleCoef] = getNetEvCorrCoef(classOut,shouldShuffle)
%getNetEvSlope.m Gets the net evidence slope from the classifier output 
%
%INPUTS
%classOUt - output of classifyNetEv
%
%OUTPUTS
%slope - value of slope
%
%ASM 8/15

if nargin < 2 || isempty(shouldShuffle)
    shouldShuffle = false;
    shuffleCoef = [];
end    

if isempty(classOut)
    corrCoef = NaN;
    return;
end

%subset 
classOut = classOut(1);

%get vals
testClass = classOut.testClass;
guess = classOut.guess;

%get corr
corr = corrcoef(testClass,guess);
corrCoef = corr(1,2);

if shouldShuffle
    shuffleGuess = classOut.shuffleGuess;
    shuffleTestClass = classOut.shuffleTestClass;
    nShuffles = size(shuffleGuess,2);
    shuffleCoef = nan(nShuffles,1);
    for shuffleInd = 1:nShuffles
        tempCorr = corrcoef(shuffleTestClass(:,shuffleInd),shuffleGuess(:,shuffleInd));
        shuffleCoef(shuffleInd) = tempCorr(1,2);
    end
end
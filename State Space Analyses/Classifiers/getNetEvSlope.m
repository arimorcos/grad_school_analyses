function slope = getNetEvSlope(classOut)
%getNetEvSlope.m Gets the net evidence slope from the classifier output 
%
%INPUTS
%classOUt - output of classifyNetEv
%
%OUTPUTS
%slope - value of slope
%
%ASM 8/15

if isempty(classOut)
    slope = NaN;
    return;
end

%subset 
classOut = classOut(1);

%get vals
testClass = classOut.testClass;
guess = classOut.guess;

%get slope
% mdl = fitlm(guess, testClass);
mdl = fitlm(testClass,guess);
slope = mdl.Coefficients.Estimate(2);
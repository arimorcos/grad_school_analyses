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

%subset 
classOut = classOut(1);

%get vals
testClass = classOut.testClass;
guess = classOut.guess;

%get slope
mdl = fitlm(guess, testClass);
slope = mdl.Coefficients.Estimate(2);
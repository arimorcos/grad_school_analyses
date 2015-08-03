function corrCoef = getNetEvCorrCoef(classOut)
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

%get corr
corr = corrcoef(testClass,guess);
corrCoef = corr(1,2);
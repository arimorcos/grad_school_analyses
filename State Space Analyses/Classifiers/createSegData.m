function [segData, trainInd, segInd] = createSegData(traces, mode, segFrac, yPosBins)
%createSegData.m Creates a segment dataset ready for svm based on the given
%mode 
%
%INPUTS
%traces - nFeatures x nBins x nTrials array 
%mode - 'across', 'grouped', or 'ind'
%segFrac - 1 x 2 array of segment fraction. Default is [0.25 0.75]
%yPosBins - y position bins 
%
%OUTPUTS 
%segData - nFeatures x (nTrials x nSeg) array of values for each segment
%trainInd - indices used to train 
%segInd - indices of same segment 
%
%ASM 3/15


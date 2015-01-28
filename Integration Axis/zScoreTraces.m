function zTraces = zScoreTraces(traces)
%zScoreTraces.m z scores traces by subtracting the mean and dividing by the
%std
%
%INPUTS
%traces - nNeurons x nBins x nTrials matrix of traces
%
%OUTPUTS
%zTraces - nNeurons x nBins x nTrials matrix of z-scored traces
%
%ASM 5/14

%subtract mean from traces
meanSubTraces = bsxfun(@minus, traces, mean(mean(traces,3),2));

%divide by standard deviation
zTraces = bsxfun(@rdivide, meanSubTraces, std(reshape(traces,size(traces,1),[]),0,2));
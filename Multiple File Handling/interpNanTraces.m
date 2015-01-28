function interpTrace = interpNanTraces(trace,interpType)
%interpLowValTraces.m Interpolates low values in traces to correct for drop
%offs to motion, etc.
%
%INPUTS
%trace - 1 x nFrames trace
%
%OUTPUTS
%interpTrace -  1 x nFrames interpolated trace 
%
%ASM 8/14

if nargin < 2 || isempty(interpType)
    interpType = 'linear';
end

%get nan ind 
nanInd = find(isnan(trace));

%create new trace
interpTrace = trace;

%generate xInd
xInd = 1:size(trace,2);

%clear out below thresh xVal
xInd(nanInd) = [];

%clear out values after last not nan
xInd(xInd > find(~isnan(trace),1,'last')) = [];

%clear out values before first not nan
xInd(xInd < find(~isnan(trace),1,'first')) = [];

%replace values with interpolated values
interpTrace(nanInd) = interp1(xInd,trace(xInd),nanInd,interpType);
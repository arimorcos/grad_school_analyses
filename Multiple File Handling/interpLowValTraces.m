function interpTrace = interpLowValTraces(trace,thresh,interpType)
%interpLowValTraces.m Interpolates low values in traces to correct for drop
%offs to motion, etc.
%
%INPUTS
%trace - 1 x nFrames trace
%thresh - absolute threshold to use. Default is 20
%
%OUTPUTS
%interpTrace -  1 x nFrames interpolated trace 
%
%ASM 8/14

if nargin < 3 || isempty(interpType)
    interpType = 'linear';
end
if ischar(thresh) %if threshold is character
    belowThreshInd = find(trace == str2double(thresh));
else
    %find indices below thresh
    belowThreshInd = find(trace <= thresh);
end

%create new trace
interpTrace = trace;

%generate xInd
xInd = 1:size(trace,2);

%clear out below thresh xVal
xInd(belowThreshInd) = [];

%clear out values after last not nan
xInd(xInd > find(~isnan(trace),1,'last')) = [];

%clear out values before first not nan
xInd(xInd < find(~isnan(trace),1,'first')) = [];

%replace values with interpolated values
interpTrace(belowThreshInd) = interp1(xInd,trace(xInd),belowThreshInd,interpType);
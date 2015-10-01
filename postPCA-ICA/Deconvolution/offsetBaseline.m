function [trace,noise] = offsetBaseline(trace,noiseSTD)
%offsets baseline to center on zero 

if nargin < 2 || isempty(noiseSTD)
    noiseSTD = 2;
end


%get the percentile values 
px = prctile(trace,5):1e-3:prctile(trace,95);

%get distribution
py = ksdensity(trace,px);

%get max value 
[~,ind] = max(py);
maxVal = px(ind);

%offset 
trace = trace - maxVal;

noise = noiseSTD*std(trace(trace > px(1) & trace < px(end)));
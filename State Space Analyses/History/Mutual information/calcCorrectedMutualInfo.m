function info = calcCorrectedMutualInfo(response,stimulus,varargin)
%calcCorrectedMutualInfo.m Calculates corrected mutual information using
%the Panzeri method
%
%INPUTS
%response - nNeurons x nTrials array or nBins x nTrials array 
%stimults - 1 x nTrials array of stimulus conditions
%
%OPTIONAL INPUTS
%method - mutual information calculation method. 'dr' or 'gs'. Default is
%   'dr'
%bias - bias correction method. 
%btsp - number of shuffles
%nBins - number of neuronal bins
%xtrp - number of extrapolations for qe bias correction
%binFunc - binning function
%
%
%OUTPUTS
%info - mutual information in bits
%
%ASM 12/14

%intialize options
options.method = 'dr';
options.bias = 'naive';
options.btsp = 100;
nBins = 2;
options.xtrp = 3;
binFunc = 'eqspace';
% options.verbose = true;

%process varargin
if nargin > 1 || ~isempty(varargin)
    if isodd(length(varargin))
        error('Must provide a name and value for each argument');
    end
    for argInd = 1:2:length(varargin) %for each argument
        switch lower(varargin{argInd})
            case 'nbins'
                nBins = varargin{argInd+1};
            case 'bias'
                options.bias = varargin{argInd+1};
            case 'method' 
                options.method = varargin{argInd+1};
            case 'btsp'
                options.btsp = varargin{argInd+1};
            case 'xtrp'
                options.xtrp = varargin{argInd+1};
            case 'binfunc'
                binFunc = varargin{argInd+1};
        end
    end
end

%error check 
assert(ismember(numel(stimulus),size(response)),'Stimulus length does not match number of response trials');
if size(response,1) == numel(stimulus)
    response = response';
end

%generate proper array
[R, nt] = buildr(stimulus, response);
R = binr(R, nt, nBins, binFunc);
options.nt = nt;

%calculate mutual information for stimulus and response
Ish = information(R,options,'Ish');

%get info 
info = Ish(1);

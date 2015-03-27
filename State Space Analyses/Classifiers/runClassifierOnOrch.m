function runClassifierOnOrch(dataPath, savePath, nShuffles)
%runs data on orchestra
%
%INPUTS
%dataPath - path to saved data (should include traces and
%   realClass and yPosBins variables)
%savePath - path to save
%nShuffles - number of shuffles
%
%ASM 3/15

%add libsvm to path
addpath(genpath('/home/asm27/libsvm'));

if nargin < 3 || isempty(nShuffles)
    nShuffles = 100;
end

%load data
load(dataPath,'traces','realClass','yPosBins');

% run classifier
[accuracy,shuffleAccuracy] = classifyAndShuffle(...
    traces, realClass, {'accuracy','shuffleaccuracy'});

%save data
save(savePath,'accuracy','shuffleAccuracy','yPosBins');



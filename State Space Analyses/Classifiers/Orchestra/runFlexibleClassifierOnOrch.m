function runClassifierOnOrch(dataPath, labelEvalStr, savePath)
%runs data on orchestra
%
%INPUTS
%dataPath - path to saved dataCell
%labelEvalStr - string to evaluate for 
%savePath - path to save
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
    traces, realClass, {'accuracy','shuffleaccuracy'},'nshuffles',nShuffles);

%save data
save(savePath,'accuracy','shuffleAccuracy','yPosBins');



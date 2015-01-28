function sigCells = findSignificantCells(sig,binThresh)
%findSignificantCells.m Finds cells which are significant for nBins >=
%binThresh
%
%INPUTS
%sig - nNeurons x nBins array of significance 
%binThresh - number of consecutive bins which must be significant
%
%OUTPUTS
%sigCells - nSigCells x 1 array
%
%ASM 1/14

%take sum of sig
nSig = zeros(size(sig,1),1);
for i = 1:size(sig,1) %for each cell
    sigReg = logical(bwlabel(sig(i,:)));
    regArea = regionprops(sigReg,'Area');
    regAreaAll = cat(2,regArea.Area);
    if ~isempty(regAreaAll)
        nSig(i) = max(regAreaAll);
    end
end

%find cells with nSig >= binThresh
sigCells = find(nSig >= binThresh);
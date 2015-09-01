function out = getOverlapSelectivityInfo(dataCell, whichAct)

%get nNeurons 
nNeurons = size(dataCell{1}.imaging.dFFTraces{1},1);
nClusters = length(whichAct);

%get selectivity index 
selInd = getSelectivityIndex(dataCell);

%get peak selectivity index 
peakAbsSelInd = max(abs(selInd),[],2);

%get variability coeff
varCoeff = calculateTrialTrialVarCoefficient(dataCell);

%get full traces 
fullTraces = cellfun(@(x) x.imaging.dFFTraces{1}, dataCell,'uniformoutput',false);
fullTraces = cat(2,fullTraces{:});
frameRate = 29;

%threshold and get nTransPerMin
threshTraces = thresholdCompleteTrace(fullTraces,2.5,3);
nTransPerMin = getNTransPerMin(threshTraces, frameRate);
nTransPerMin = nTransPerMin{1};

%convert whichAct to nNeurons x nClusters logical
actNeurons = zeros(nNeurons, nClusters);
for cluster = 1:nClusters
    actNeurons(whichAct{cluster},cluster) = 1;
end

%define overlapping neurons 
nActiveClusters = sum(actNeurons,2);
nonOverlapping = nActiveClusters < 2;
oneCluster = nActiveClusters == 1;
overlapping = nActiveClusters > 2;

%get peak selInd for overlapping and nonOverlapping
out.overlappingSelInd = peakAbsSelInd(overlapping);
out.nonOverlappingSelInd = peakAbsSelInd(nonOverlapping);

%get varCoeff for overlapping and nonOverlapping
out.overlappingVarCoeff = varCoeff(overlapping);
out.nonOverlappingVarCoeff = varCoeff(nonOverlapping);

%get nTransPerMin for overlapping and nonOverlapping
out.overlappingNTrans = nTransPerMin(overlapping);
out.nonOverlappingNTrans = nTransPerMin(nonOverlapping);
out.oneClusterNTrans = nTransPerMin(oneCluster);

%get actNeurons
out.actNeurons = actNeurons;

%store 

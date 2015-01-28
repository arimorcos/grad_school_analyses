function [mixedSig,mixedFilters,covEigenvalues] = fastCellSortPCA(file,nPCs)

if nargin < 2 || isempty(nPCs)
    nPCs = 1000;
end

%get tiff nStrips
[~,~,nStrips] = getTiffHeightWidth(file);

%get nFrames
nFrames = getNPages(file);

covMat = zeros(nFrames);

%for each strip
for i = 1:nStrips
    
    %load strip and convert to single
    tiff = single(loadtiffAM(file,[],i));
    
    %reshape into nPixels x nFrames
    tiff = reshape(tiff,size(tiff,1)*size(tiff,2),size(tiff,3));
    
    %normalize
    meanTiff = mean(tiff,2);
    tiff = tiff./repmat(meanTiff,1,size(tiff,2));
    tiff = tiff - 1;
    
    %get covariance matrix
    covMat = covMat + cov(tiff);
    
    disp(i);
end

%get mean covariance matrix
meanCovMat = covMat./nStrips;

%get eigenvectors and eigenvalues
[eigenvectors,covEigenvalues] = eig(meanCovMat);
covEigenvalues = flipud(diag(covEigenvalues));
eigenvectors = fliplr(eigenvectors);
eigenvectors = eigenvectors(:,1:nPCs);
covEigenvalues = double(covEigenvalues(1:nPCs));

%load entire tiff
tiff = single(loadtiffAM(file));
reshapeTiff = reshape(tiff,size(tiff,1)*size(tiff,2),size(tiff,3));
meanReshapeTiff = mean(reshapeTiff,2);
reshapeTiff = reshapeTiff./repmat(meanReshapeTiff,1,size(reshapeTiff,2));
reshapeTiff = reshapeTiff - 1;

%project onto first 1000 eigenvectors
projection = eigenvectors'*reshapeTiff';
projection = projection - repmat(mean(projection,2),1,size(projection,2));
projection = projection./repmat(std(projection,0,2),1,size(projection,2));

mixedSig = double(eigenvectors);
mixedFilters = double(reshape(projection',size(tiff,1),size(tiff,2),[]));
    

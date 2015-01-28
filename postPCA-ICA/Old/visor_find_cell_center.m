% This function detects the centers of cells in an image

function funcOut = visor_find_cell_center(image_in, cell_radius, threshold)
global Igd
if mod(cell_radius,2)==0
    cell_radius = cell_radius+1;
end

image_in_orig = image_in;


%% one-dimensional gaussian filter.
sigma=cell_radius/sqrt(2);
fs=ceil(sigma);
ssq =sigma*sigma;
t = -fs*3:fs*3;
gf = exp(-(t.*t)/(2*ssq))/sqrt(2*pi*ssq); 
gf = gf/sum(gf);

%% two-dimensional laplacian of gaussian filter
logf=-fspecial('log',cell_radius,1); %%%%MOD

%% Spatial summation by 2-D Gaussian fitering of the image. 
% Fast implementation using separate one-dimensional filtering.
Ig=imfilter(image_in,gf,'symmetric');
Ig=imfilter(Ig,gf','symmetric'); 
%figure,imagesc(Ig),axis image;colormap gray

%% subtract background by taking the derivative of gaussian filtered images
Igd=imfilter(Ig,logf,'symmetric'); 
%figure,imagesc(Igd),axis image;colormap gray

%% determine the threshold for peak selection. 
% assume the cells occupy a relatively small proportion of the image
gm=median(Igd(:));
sd=median(abs(Igd(:)-gm))/0.6745; 
    % use median-of-the-absolute-deviation-from-the-median to estimate   
    % noise standard deviation

%% threshold filtered image to reject noises
Ithr=Igd>sd*threshold; % user defined threshold value for noise rejection
    % 4 or 5 maybe needed for large images to keep false positives low

%% find local maxima in the filtered image
se=repmat(1,[3 3]);
Idl=imdilate(Igd,se);
Imax= Igd==Idl;

%% combine noise rejection and local maxima detection
Ic=Imax & Ithr;

% find row and column index of the cell centers
[ri ci]=ind2sub(size(Ic),find(Ic));

%% remove centers within one-cell radius from the border
centers=[ri ci];
%size(centers);
%[rl, cl]=size(Ic);
%cell_radius_temp = cell_radius;
%cell_radius = 3;
%centers(ri<cell_radius|ri>rl-cell_radius|ci<cell_radius|ci>cl-cell_radius,:)=[];
%cell_radius = cell_radius_temp;

%Cs = zeros(size(image_in));
%Cell_circs = zeros(size(image_in,1),size(image_in,2),length(centers));


%% make ROIs, based on Ithr -jms june09
[B,L] = bwboundaries(Ithr,'noholes');
ind = 0;
whichCells = zeros(length(B),1);
for i = 1:1:length(B)
	
    if length(B{i})>=10
		whichCells(i) = 1;
        ind = ind+1;
        temp = zeros(size(image_in));
        [x,y] = find(L==i);
        for xx = 1:length(x)
            temp(x(xx),y(xx)) = 1;
        end
        ROIs(:,:,ind) = temp;
		
    end
end

if ~sum(whichCells>0)
	funcOut = [];
	disp('No cells found.');
	return;
end

disp([num2str(size(ROIs,3)), ' Cells found'])

centers = zeros(size(ROIs,3),2);
for i = 1:size(ROIs,3)
    stat = regionprops(ROIs(:,:,i),'Centroid');
    centers(i,:) = stat.Centroid;
end

%function output struct
funcOut.Igd = Igd;
funcOut.centers = centers;
% funcOut.circs = Cell_circs;
funcOut.Ithr = Ithr;
funcOut.ROI = ROIs;




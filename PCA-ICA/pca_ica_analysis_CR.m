
fn = 'D:\DATA\2P Data\ResScan\Laura\LD57_130905_001_cat\LD57_130905_001_cat_Plane002_motionCorrected.tif';  
outputdir = 'D:\DATA\2P Data\ResScan\Laura\LD57_130905_001_cat';
% pclamp_directory = 'D:\AC data\pclamp files\2013-05-29\S3\A1 - Site 2\'
frames_per_trial = 3000;
frame_rate = 15.62;

close all
i = imfinfo(fn);

f0 = imread(fn);
flims = [1 length(i)];

nPCs = [167];

dsamp = [];

badframes = [];

mu = 0.2;
nIC = [];
ica_A_guess = [];
termtol = [];
maxrounds = [1000];

mode = 'contour';
mode = 'series';

tlims = [1 flims(2)/15.62];
dt = 1/frame_rate;
ratebin = 5;
plottype = 1;
ICuse = [];

smwidth = 3;
thresh = [];
arealims = [3];
plotting = 1;

subtractmean = 1;


normalization = 1;

[mixedsig, mixedfilters, CovEvals, covtrace, movm, movtm] =...
    CellsortPCA(fn, flims, nPCs, dsamp, outputdir, badframes);

[PCuse] = CellsortChoosePCs(fn, mixedfilters);

CellsortPlotPCspectrum(fn, CovEvals, PCuse);

[ica_sig, ica_filters, ica_A, numiter] =...
    CellsortICA(mixedsig,mixedfilters, CovEvals, PCuse, mu, nIC, ica_A_guess, termtol, maxrounds);
% 
% thresh = 2;
% deconvtau = .001;
% [spmat, spt, spc,zsig] = CellsortFindspikes(ica_sig, thresh, dt, deconvtau, normalization);


data.ica_filters = ica_filters;
    
% CellsortICAplot(mode, ica_filters, ica_sig, f0, tlims, dt, ratebin, plottype, ICuse);%, spt, spc) ;

thresh = [];
[ica_segments, segmentlabel, segcentroid] = CellsortSegmentation(ica_filters, smwidth, thresh, arealims, plotting);

% cell_sig = CellsortApplyFilter(fn, ica_segments, flims, movm, subtractmean);

% [raw] = Reduced_data(icasig);
[rois,filter_id] = select_cell_segments(ica_filters,ica_segments,segmentlabel);


data.sampling_rate = frame_rate;

scanimage_fn = fn;

data = line_up_multitiff_pclamp_files(scanimage_fn,pclamp_directory,frame_rate,frames_per_trial);  

data.rois = rois;
data.filter_id = filter_id;

for trial = 1:size(data.F,1);
    for cel = 1:size(rois,1);
    data.Fav(trial,cel,:) = get_Fav(squeeze(data.F(trial,:,:,:)),data.rois(cel,:,:));
    end
end
data.stimulus_on = 1;
data.stimulus_off = 9;
data.sampling_rate = frame_rate;
global data

get_dff_traces(data,data.Fav);

plot_all_responses_SAMnoise_cat

random_sound_inds = [10 15 1 2 5 11 14 7 9 4 3 16 6 8 12 13];
[x,inds] = sort(random_sound_inds);
data.sorted = sort_for_multiple_repeats(data,15,1,inds);
curve_fitting_car

for cel = 1:size(data.sorted.dFF_traces,2);
    dFF_normalized(:,cel,:,:) = data.sorted.dFF_traces(:,cel,:,:)./squeeze(max(max(mean(data.sorted.dFF_traces(:,cel,:,:)))));
end

stimulus_trajectory = data.sorted.dFF_traces(:,find(data.real_cells),:,(off_frames/2):end);

    


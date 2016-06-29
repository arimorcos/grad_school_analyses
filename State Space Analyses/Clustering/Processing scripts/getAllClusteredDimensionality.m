%
saveFolder = '/Users/arimorcos/Data/Analyzed Data/160221_vogel_sep_dimensionality';

% get list of datasets
procList = getProcessedList();
nDataSets = length(procList);

%get deltaPLeft
for dSet = 1:nDataSets
    %dispProgress
    dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
    
    %load in data
    loadProcessed(procList{dSet}{:},[],'oldDeconv_smooth10');

    %process
    out_left = getClusteredDimensionality(correctLeft60);
    out_right = getClusteredDimensionality(correctRight60);
    out.frac_explored = mean(...
        cat(1, out_left.frac_explored', out_right.frac_explored'), 1);
    
    %save
    saveName = fullfile(saveFolder,sprintf('%s_%s_cluster_dim.mat',procList{dSet}{:}));
    save(saveName,'out', 'out_left', 'out_right');
    
end
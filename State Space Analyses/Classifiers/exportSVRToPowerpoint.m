datasets = {'AM136_140820','AM142_141218','AM144_141203','AM150_141128'};

for set = datasets
    
    %convert to latex appropriate
    texSet = strrep(set,'_','\_');
    texSet = texSet{1};
    
    % label data set
    toPPT('setTitle',sprintf('Dataset: %s',texSet),'SlideNumber','append')
    
    % create strings 
    netEvStr = sprintf('%s_SVR_classifierOut_netEv',set{1});
    numLeftStr = sprintf('%s_SVR_classifierOut_numLeft',set{1});
    numRightStr = sprintf('%s_SVR_classifierOut_numRight',set{1});
    netEvStrTMatch = sprintf('%s_SVR_classifierOut_netEv_tMatch',set{1});
    numLeftStrTMatch = sprintf('%s_SVR_classifierOut_numLeft_tMatch',set{1});
    numRightStrTMatch = sprintf('%s_SVR_classifierOut_numRight_tMatch',set{1});
    
    %load netEv 
    load(netEvStr);
    
    %plot ind
    figH = plotClassifierOutIndSegSVM(indClassifier);
    pause(0.3);
    toPPT(figH);
    toPPT('setTitle',sprintf('%s\\_indSeg\\_SVR\\_netEv',texSet));
    delete(figH);
    
    %plot group
    figH = plotClassifierOutGroupSegSVM(groupClassifier);
    pause(0.3);
    toPPT(figH);
    toPPT('setTitle',sprintf('%s\\_groupSeg\\_SVR\\_netEv',texSet));
    delete(figH);
    
    %plot across
    figH = plotClassifierOutGroupSegSVM(acrossClassifier);
    pause(0.3);
    toPPT(figH);
    toPPT('setTitle',sprintf('%s\\_acrossSeg\\_SVR\\_netEv',texSet));
    delete(figH);
    
    %load trial matched 
    load(netEvStrTMatch);
    
    %plot trial matched group 
    figH = plotClassifierOutGroupSegSVM(groupClassifier);
    pause(0.3);
    toPPT(figH);
    toPPT('setTitle',sprintf('%s\\_groupSeg\\_SVR\\_netEv\\_trialMatch',texSet));
    delete(figH);
    
    %plot trial matched across
    figH = plotClassifierOutGroupSegSVM(acrossClassifier);
    pause(0.3);
    toPPT(figH);
    toPPT('setTitle',sprintf('%s\\_acrossSeg\\_SVR\\_netEv\\_trialMatch',texSet));
    delete(figH);
    
    %load numLeft 
    load(numLeftStr);
    
    %plot ind
    figH = plotClassifierOutIndSegSVM(indClassifier);
    pause(0.3);
    toPPT(figH);
    toPPT('setTitle',sprintf('%s\\_indSeg\\_SVR\\_numLeft',texSet));
    delete(figH);
    
    %plot group
    figH = plotClassifierOutGroupSegSVM(groupClassifier);
    pause(0.3);
    toPPT(figH);
    toPPT('setTitle',sprintf('%s\\_groupSeg\\_SVR\\_numLeft',texSet));
    delete(figH);
    
    %plot across
    figH = plotClassifierOutGroupSegSVM(acrossClassifier);
    pause(0.3);
    toPPT(figH);
    toPPT('setTitle',sprintf('%s\\_acrossSeg\\_SVR\\_numLeft',texSet));
    delete(figH);
    
    %load trial matched 
    load(numLeftStrTMatch);
    
    %plot trial matched group 
    figH = plotClassifierOutGroupSegSVM(groupClassifier);
    pause(0.3);
    toPPT(figH);
    toPPT('setTitle',sprintf('%s\\_groupSeg\\_SVR\\_numLeft\\_trialMatch',texSet));
    delete(figH);
    
    %plot trial matched across
    figH = plotClassifierOutGroupSegSVM(acrossClassifier);
    pause(0.3);
    toPPT(figH);
    toPPT('setTitle',sprintf('%s\\_acrossSeg\\_SVR\\_numLeft\\_trialMatch',texSet));
    delete(figH);
    
    %load numRight 
    load(numRightStr);
    
    %plot ind
    figH = plotClassifierOutIndSegSVM(indClassifier);
    pause(0.3);
    toPPT(figH);
    toPPT('setTitle',sprintf('%s\\_indSeg\\_SVR\\_numRight',texSet));
    delete(figH);
    
    %plot group
    figH = plotClassifierOutGroupSegSVM(groupClassifier);
    pause(0.3);
    toPPT(figH);
    toPPT('setTitle',sprintf('%s\\_groupSeg\\_SVR\\_numRight',texSet));
    delete(figH);
    
    %plot across
    figH = plotClassifierOutGroupSegSVM(acrossClassifier);
    pause(0.3);
    toPPT(figH);
    toPPT('setTitle',sprintf('%s\\_acrossSeg\\_SVR\\_numRight',texSet));
    delete(figH);
    
    %load trial matched 
    load(numRightStrTMatch);
    
    %plot trial matched group 
    figH = plotClassifierOutGroupSegSVM(groupClassifier);
    pause(0.3);
    toPPT(figH);
    toPPT('setTitle',sprintf('%s\\_groupSeg\\_SVR\\_numRight\\_trialMatch',texSet));
    delete(figH);
    
    %plot trial matched across
    figH = plotClassifierOutGroupSegSVM(acrossClassifier);
    pause(0.3);
    toPPT(figH);
    toPPT('setTitle',sprintf('%s\\_acrossSeg\\_SVR\\_numRight\\_trialMatch',texSet));
    delete(figH);
    
    
end
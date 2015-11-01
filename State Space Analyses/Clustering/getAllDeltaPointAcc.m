%saveFolder
saveFolder = '/Users/arimorcos/Data/Analyzed Data/151023_vogel_autoCorr_deltaPoint';

%get list of datasets
procList = getProcessedList();
nDataSets = length(procList);
% perc = [1 10 30 50 70];
perc = [10];

%get deltaPLeft
for dSet = 8:nDataSets
    for percVal = perc
        % for dSet = 7
        %dispProgress
        dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
        
        %load in data
        loadProcessed(procList{dSet}{:},[],'oldDeconv_smooth10');
        
        %get deconv all
        [~,~,deltaPoint,nUnique] = calcTrajPredictabilityUnified(imTrials,'traceType','deconv',...
            'perc',percVal,'filterAutoCorr',true,'filterAutoCorrThresh',0.05,...
            'filterAutoCorrLag',4,'filterAutoCorrRemoveRandom',false);
        
        %save
        saveName = fullfile(saveFolder,sprintf(...
            '%s_%s_deltaPoint_all_deconv_lag_%d_thresh_%d.mat',...
            procList{dSet}{:}, 4, 05));
        save(saveName,'deltaPoint','nUnique');
    end
end





%get dff delta point
%         [~,~,deltaPoint,nUnique] = calcTrajPredictability(left60,'traceType','dff',...
%             'perc',percVal);
%
%         %save
%         saveName = fullfile(saveFolder,sprintf('%s_%s_deltaPoint_left_dFF_perc%d.mat',procList{dSet}{:},percVal));
%         save(saveName,'deltaPoint','nUnique');

%get dff deconv
%             [~,~,deltaPoint,nUnique] = calcTrajPredictability(left60,'traceType','deconv',...
%                 'perc',percVal);
%
%             %save
%             saveName = fullfile(saveFolder,sprintf('%s_%s_deltaPoint_left_deconv_%d.mat',procList{dSet}{:},percVal));
%             save(saveName,'deltaPoint','nUnique');

%get dff delta point
%         [~,~,deltaPoint,nUnique] = calcTrajPredictability(right60,'traceType','dff',...
%             'perc',percVal);
%
%         %save
%         saveName = fullfile(saveFolder,sprintf('%s_%s_deltaPoint_right_dFF_perc%d.mat',procList{dSet}{:},percVal));
%         save(saveName,'deltaPoint','nUnique');

%get dff deconv
%             [~,~,deltaPoint,nUnique] = calcTrajPredictability(right60,'traceType','deconv',...
%                 'perc',percVal);
%
%             %save
%             saveName = fullfile(saveFolder,sprintf('%s_%s_deltaPoint_right_deconv_%d.mat',procList{dSet}{:},percVal));
%             save(saveName,'deltaPoint','nUnique');

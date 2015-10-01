%saveFolder
saveFolder = 'D:\DATA\Analyzed Data\150925_dFF_deltaPointAcc_past_future';

%get list of datasets
procList = getProcessedList();
nDataSets = length(procList);
% perc = [1 10 30 50 70];
perc = [10];

%get deltaPLeft
for dSet = 1:nDataSets
    for percVal = perc
        % for dSet = 7
        %dispProgress
        dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
        
        %load in data
        loadProcessed(procList{dSet}{:},[],'oldDeconv_smooth10');
        
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
        
        
        %get deconv all
        [~,~,deltaPoint,nUnique] = calcTrajPredictabilityUnified(imTrials,'traceType','dFF',...
            'perc',percVal);
        
        %save
        saveName = fullfile(saveFolder,sprintf('%s_%s_deltaPoint_all_dFF_%d.mat',procList{dSet}{:},percVal));
        save(saveName,'deltaPoint','nUnique');
    end
end
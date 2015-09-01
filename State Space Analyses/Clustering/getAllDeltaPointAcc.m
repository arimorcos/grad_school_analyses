%saveFolder
saveFolder = 'D:\DATA\Analyzed Data\150730_deltaPointAcc_all';

%get list of datasets
procList = getProcessedList();
nDataSets = length(procList);
perc = [1 10 30 50 70];

%get deltaPLeft
for dSet = 1:nDataSets
    for percVal = perc
        % for dSet = 7
        %dispProgress
        dispProgress('Processing dataset %d/%d',dSet,dSet,nDataSets);
        
        %load in data
        loadProcessed(procList{dSet}{:});
        
        %get dff delta point
%         [~,~,deltaPoint,nUnique] = calcTrajPredictability(left60,'traceType','dff',...
%             'perc',percVal);
%         
%         %save
%         saveName = fullfile(saveFolder,sprintf('%s_%s_deltaPoint_left_dFF_perc%d.mat',procList{dSet}{:},percVal));
%         save(saveName,'deltaPoint','nUnique');
        
        %get dff deconv
            [~,~,deltaPoint,nUnique] = calcTrajPredictability(left60,'traceType','deconv',...
                'perc',percVal);
        
            %save
            saveName = fullfile(saveFolder,sprintf('%s_%s_deltaPoint_left_deconv_%d.mat',procList{dSet}{:},percVal));
            save(saveName,'deltaPoint','nUnique');
        
        %get dff delta point
%         [~,~,deltaPoint,nUnique] = calcTrajPredictability(right60,'traceType','dff',...
%             'perc',percVal);
%         
%         %save
%         saveName = fullfile(saveFolder,sprintf('%s_%s_deltaPoint_right_dFF_perc%d.mat',procList{dSet}{:},percVal));
%         save(saveName,'deltaPoint','nUnique');
        
        %get dff deconv
            [~,~,deltaPoint,nUnique] = calcTrajPredictability(right60,'traceType','deconv',...
                'perc',percVal);
        
            %save
            saveName = fullfile(saveFolder,sprintf('%s_%s_deltaPoint_right_deconv_%d.mat',procList{dSet}{:},percVal));
            save(saveName,'deltaPoint','nUnique');
    end
end
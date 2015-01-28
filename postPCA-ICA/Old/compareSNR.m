%get nTraces
nTraces = size(sinFrameRSNR,1);

%calculate nFigures
nFigures = ceil(nTraces/16);


%loop through each figure and plot
for i = 1:nFigures
    figure('Name','CDF of SNR');
    for plotInd = 1:16
        
        cellNum = (i-1)*16 + plotInd;
        if cellNum > nTraces || cellNum == 58
            continue;
        end
        subplot(4,4,plotInd);
        [f,x] = ecdf(dFFSNR(i,:));        
        plot(x,f,'g');
        hold on;
        [f,x] = ecdf(sinFrameRSNR(i,:));        
        plot(x,f,'r');
        [f,x] = ecdf(percGRSNR(i,:));        
        plot(x,f,'b');
        
        title(sprintf('Cell %d',cellNum));
    end
    if i == 1;
        return;
    end
end
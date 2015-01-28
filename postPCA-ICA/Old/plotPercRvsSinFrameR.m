%get nTraces
nTraces = size(sinFrameRTraces,1);

%calculate nFigures
nFigures = ceil(nTraces/16);


%loop through each figure and plot
for i = 1:nFigures
    figure('Name','PercR vs. SinFrame R');
    for plotInd = 1:16
        
        cellNum = (i-1)*16 + plotInd;
        if cellNum > nTraces || cellNum == 58
            continue;
        end
        subplot(4,4,plotInd);
        plot(dFFTraces(cellNum,:),'g');
        hold on;
        plot(sinFrameRTraces(cellNum,:),'r');
        plot(percRTraces(cellNum,:),'b');
        
        title(sprintf('Cell %d',cellNum));
        totTrace = [sinFrameRTraces(cellNum,:) percRTraces(cellNum,:) dFFTraces(cellNum,:)];
        ylim([min(totTrace)-1 max(totTrace)+1]);
    end
    if i == 1;
        return;
    end
end
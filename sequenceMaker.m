t = 10000;
n = 50;
sortFlag = true;
sortFrac = 1;
removeAct = false;
remProb = 0;
noSeq = false;
noSeqInd = [.1:.1:.9];
jitter = false;
persAct = false;
persStart = 0.5; %must be greater than .1
fracUp = .5;
persEnd = 0.9;



shape = [linspace(1,10,round(.05*t)),10,linspace(10,1,round(.05*t))];
x = zeros(n,t);
if persAct
    maxInd = t*(persStart);
    persLength = length(maxInd:(t*persEnd));
    turnLength = length(x(1,(t*persEnd)+1:end));
    for i=1:n
        if i < n*fracUp
            max = randn(1)+8;
            x(i,1:maxInd) = linspace(4,max,maxInd);
            x(i,maxInd:(t*persEnd)) = 0.5*randn(1,persLength)+max;
            x(i,(t*persEnd)+1:end) = linspace(max,4,turnLength);
        else
            x(i,1:maxInd) = linspace(4,0,maxInd);
            x(i,maxInd:(t*persEnd)) = rand(1,persLength);
            x(i,(t*persEnd)+1:end) = linspace(0,4,turnLength);
        end
    end
else
    for i=1:n
        if noSeq
            ind = t*noSeqInd(randi([1 length(noSeqInd)]));
        else
            ind = randi([.05*t t-.05*t]);
        end
        if jitter
            ind = round(ind + randn*t/30);
        end
    x(i,ind-.05*t:ind+.05*t) = shape;
    end
end

if sortFlag
    if sortFrac ~= 1
        sortSplit = round((1-sortFrac)*n);
        y = sortTimeMax(x);
        y(sortSplit:end,:) = x(sortSplit:end,:);
        if removeAct
            for i=sortSplit:n
                if rand < remProb
                    y(i,:) = zeros(1,t);
                end
            end
        end

    else
        y = sortTimeMax(x);
    end
else
    y = x;
    if removeAct
        for i=1:n
            if rand < remProb
                y(i,:) = zeros(1,t);
            end
        end
    end
end

figure;
imagesc(y,[0 15])
colorbar('Ticks',[0 15],'TickLabels',{'Min','Max'});
xlabel('Time (s)');
ylabel('Neuron # (sorted)');

line([.5*t .5*t],[0 n],'LineWidth',2,'Color','k');
line([.9*t .9*t],[0 n],'LineWidth',2,'Color','k');
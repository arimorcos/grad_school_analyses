function plotExtIntStruc(extInt)
%plotExtIntStruc.m Plot output of external vs. internal
%
%INPUTS
%extInt - structure output by quantifyExtIntVariability
%
%ASM 4/15

confInt = 99;

%create figure
figH = figure;

%%%% plot ratio 

axRatio = subplot(1,2,1);
hold(axRatio,'on');

%get confidence intervals
lowInd = (100-confInt)/2;
highInd = 100-lowInd;
confVals = prctile(extInt.shuffleRatio,[lowInd highInd]);
confVals = abs(bsxfun(@minus,confVals,median(extInt.shuffleRatio)));

%get nSeg
nSeg = length(extInt.ratio);

%plot
scatRatio = scatter(1:nSeg,extInt.ratio);
errRatio = errorbar(1:nSeg,median(extInt.shuffleRatio),confVals(1,:),confVals(2,:));

%customize
scatRatio.MarkerFaceColor = 'flat';
scatRatio.SizeData = 100;
errRatio.LineStyle = 'none';
errRatio.Color = 'r';
errRatio.LineWidth = 2;
axis(axRatio,'square');
axRatio.FontSize = 20;
axRatio.XTick = 1:nSeg;

%label
axRatio.YLabel.String = 'External/Internal Ratio';
axRatio.YLabel.FontSize = 30;
axRatio.XLabel.String = 'Segment #';
axRatio.XLabel.FontSize = 30;

%%%% plot absExt/int 

axExtInt = subplot(1,2,2);
hold(axExtInt,'on');

%%% external different seg
%get confidence intervals for ext 
lowInd = (100-confInt)/2;
highInd = 100-lowInd;
confValsExt = prctile(extInt.shuffleAbsExt,[lowInd highInd]);
confValsExt = abs(bsxfun(@minus,confValsExt,median(extInt.shuffleAbsExt)));

%get nSeg
nSeg = length(extInt.ratio);

%plot
scatRatioExt = scatter(1:nSeg,extInt.absExt);
errRatioExt = errorbar(1:nSeg,median(extInt.shuffleAbsExt),confValsExt(1,:),confValsExt(2,:));

%customize
scatRatioExt.MarkerFaceColor = 'b';
scatRatioExt.SizeData = 100;
errRatioExt.LineStyle = 'none';
errRatioExt.Color = 'b';
errRatioExt.LineWidth = 2;

%%% internal 
%get confidence intervals for ext 
lowInd = (100-confInt)/2;
highInd = 100-lowInd;
confValsInt = prctile(extInt.shuffleAbsInt,[lowInd highInd]);
confValsInt = abs(bsxfun(@minus,confValsInt,median(extInt.shuffleAbsInt)));

%get nSeg
nSeg = length(extInt.ratio);

%plot
scatRatioInt = scatter(1:nSeg,extInt.absInt);
errRatioInt = errorbar(1:nSeg,median(extInt.shuffleAbsInt),confValsInt(1,:),confValsInt(2,:));

%customize
scatRatioInt.MarkerFaceColor = 'r';
scatRatioInt.SizeData = 100;
errRatioInt.LineStyle = 'none';
errRatioInt.Color = 'r';
errRatioInt.LineWidth = 2;

%%% external same seg 
%get confidence intervals for ext 
lowInd = (100-confInt)/2;
highInd = 100-lowInd;
confValsAbsExtSameSeg = prctile(extInt.shuffleAbsExtSameSeg,[lowInd highInd]);
confValsAbsExtSameSeg = abs(bsxfun(@minus,confValsAbsExtSameSeg,median(extInt.shuffleAbsExtSameSeg)));

%get nSeg
nSeg = length(extInt.ratio);

%plot
scatRatioAbsExtSameSeg = scatter(1:nSeg,extInt.absExtSameSeg);
errRatioAbsExtSameSeg = errorbar(1:nSeg,median(extInt.shuffleAbsExtSameSeg),...
    confValsAbsExtSameSeg(1,:),confValsAbsExtSameSeg(2,:));

%customize
scatRatioAbsExtSameSeg.MarkerFaceColor = 'g';
scatRatioAbsExtSameSeg.SizeData = 100;
errRatioAbsExtSameSeg.LineStyle = 'none';
errRatioAbsExtSameSeg.Color = 'g';
errRatioAbsExtSameSeg.LineWidth = 2;


axis(axExtInt,'square');
axExtInt.FontSize = 20;
axExtInt.XTick = 1:nSeg;

%label
axExtInt.YLabel.String = 'Fraction of cluster pairs ending in different clusters';
axExtInt.YLabel.FontSize = 20;
axExtInt.XLabel.String = 'Segment #';
axExtInt.XLabel.FontSize = 30;
legend([scatRatioExt scatRatioInt scatRatioAbsExtSameSeg],...
    {'External (diff marg. seg)','Internal','External (same marg. seg)'},'Location','Best');
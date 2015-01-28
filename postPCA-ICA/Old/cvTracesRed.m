%% load necessary variables
redMovie = loadtiffAM('K:\Data\2P Data\ResScan\AM115\140227\AM115_1_3x_119Sub_001_red_cat_motionCorrected_crop.tif');
load('K:\Data\2P Data\ResScan\AM115\140227\AM115_1_3x_119Sub_001_red_cat_motionCorrected_crop_manualROI.mat');
red = loadtiffAM('K:\Data\2P Data\ResScan\AM115\140227\AM115_1_3x_119Sub_001_red_cat_motionCorrected_zProj_crop.tif');
load('K:\Data\2P Data\ResScan\AM115\140227\AM115_1_3x_119Sub_001_green_cat_motionCorrected_crop_postICA.mat');

%% get red traces

filterTraces = getRedTraces(redMovie,filteredSegNonOverlap);
noCellTraces = getRedTraces(redMovie,ROIs);

%%


meanTraces = mean(filterTraces,2);
stdTraces = std(filterTraces,0,2);
cvTraces = stdTraces./meanTraces;
cvTraces = cvTraces(~isnan(cvTraces));
meanRedExpression=getMedianRedExpression(filteredSegNonOverlap,red,0);
meanRedExpression = meanRedExpression(~isnan(meanRedExpression));

scatter(cvTraces,meanRedExpression)
xlabel('CV');
ylabel('Mean Red Expression')





meanNoCellTraces = mean(noCellTraces,2);
stdNoCellTraces = std(noCellTraces,0,2);
cvNoCellTraces = stdNoCellTraces./meanNoCellTraces;
cvNoCellTraces = cvNoCellTraces(~isnan(cvNoCellTraces));
meanRedExpressionNoCell = getMedianRedExpression(ROIs,red,0);
meanRedExpressionNoCell = meanRedExpressionNoCell(~isnan(meanRedExpressionNoCell));

hold on;
scatter(cvNoCellTraces,meanRedExpressionNoCell);
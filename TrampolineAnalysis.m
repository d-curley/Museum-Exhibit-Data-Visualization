w = warning('off','MATLAB:thingSpeakRead:numPointsUnmet');
trampolineData = thingSpeakRead(573246,'Numminutes',4000,'OutputFormat','timetable'); %maT3chi3!
warning(w);
trampolineData.Properties.VariableNames{1} = 'BounceHeight';
WeekBounces = trampolineData.BounceHeight;
yesterdayData = trampolineData(trampolineData.Timestamps > dateshift(trampolineData.Timestamps(end),'start','day'),:);
DayBounces= yesterdayData.BounceHeight;

%Graphing Variables
pink=[1 0.4 0.6];
grey=[.8 .8 .8];
green=[.66 .85 .58];
DotSize=350;
space=5;

%%  Histogram Visualization Setup
clf
figSize = get(gcf,'Position');
figSize(4) = 1000;
figSize(3) = figSize(4);
set(gcf,'Position',figSize,'Color','w');

%Last Week Bounces
[Dots q] = size(WeekBounces);

%Sets the Y and X coordinates so scatterplot can be used as a histogram
for iDot = 1:Dots
    YPos(iDot)= ceil(WeekBounces(iDot)/4)*4; %Taking the bounce height divided by 4 designates bin#
    BinX(iDot) = histc(YPos(:),YPos(iDot));
end

%Graph Last Weeks Bounces
hHist=scatter(BinX,YPos,DotSize,grey,'filled');
hold on

%Todays Bounces
[pDots q] = size(DayBounces);

%Sets the Y and X coordinates so scatterplot can be used as a histogram
for iDot = 1:pDots
    pYPos(iDot) = ceil(DayBounces(iDot)/4)*4; %Taking the bounce height divided by 4 designates bin#
    pBinX(iDot) = histc(pYPos(:),pYPos(iDot));
end

%Graph Todays Bounces (so far) 
aHist=scatter(pBinX,pYPos,DotSize,pink,'filled');
hold on
aHist = hHist.Parent; %specific to figures

%Defines  important values to be tagged 
high=ceil(max(DayBounces)/4)*4;
low=ceil(min(DayBounces)/4)*4;
most=mode(ceil(DayBounces/4)*4);
Record = ceil(pYPos/4)*4;
 
scatter(histc(Record,high),high,DotSize,'w','p','filled');
scatter(histc(Record,low),low,DotSize,'y','p','filled');
scatter(histc(Record,most),most,DotSize,grey,'p','filled');


%% Graph Details

% Title
title("Trampoline Bounce Heights")
aHist.TitleFontSizeMultiplier = 2.5;

% X Axis
xlabel("Number of Bounces")
labelFontSize = round(aHist.XAxis.Label.FontSize);
aHist.XAxis.Label.FontSize = labelFontSize;
tickFontSize = labelFontSize; 
aHist.XAxis.FontSize = tickFontSize*2;

% Y Axis (Center)
aHist.YAxis.Limits = [-0.5 max(union(DayBounces,WeekBounces))+5];
aHist.YAxisLocation = 'Left';
aHist.YAxis.TickLabelFormat = '%dcm';
aHist.YAxis.FontSize = tickFontSize * 2;
aHist.YAxis.Visible = true;
aHist.YGrid = 'on';

%% Arrows for recent tests
recentruns = round(WeekBounces(end-2:end));

% Arrows Display
arrowSize = .2; 
histPosition = hHist.Parent.Position ;
histPosition(1) = histPosition(1);
arrowPosition = histPosition;
histPosition(1) = histPosition(1) + .26;
histPosition(3) = histPosition(3)-.2;
hHist.Parent.Position = histPosition;
arrowPosition(3) = arrowSize;
aArrows = axes('Position',arrowPosition);
set(gca,'Color',green);

% X Axis under arrows
aArrows.XAxis.Limits = [0 4];
set(gca,'xticklabel',{[]});
xlabel("Recent Tests",'FontSize',30)

% Y Axis (left)
ylabel("Bounce Height",'FontSize',32)
aArrows.YAxis.Limits = [-0.5 max(union(DayBounces,WeekBounces))+5];
set(gca,'LineWidth',24,'YGrid','on','TickLength',[0 0],'yticklabel',{[]})
aArrows.XRuler.Axle.LineWidth = .01;
aArrows.YRuler.Axle.LineWidth = .01;

figSize = get(gcf,'Position');
circlesize = [figSize(4) figSize(3)] / figSize(3) / 40;

%Plot Recent Tests
for iRun = 1:size(recentruns,1)
    [xArrowStart,yArrowStart] = convertDataToNormalizedUnits(aArrows,iRun,0);
    [xArrowEnd,yArrowEnd] = convertDataToNormalizedUnits(aArrows,iRun,recentruns(iRun));
    
    xTriangle(iRun,:)=[iRun - .15,iRun + .15,iRun,iRun - .15];
    yTriangle(iRun,:)=[recentruns(iRun),recentruns(iRun),0,recentruns(iRun)];
    line(xTriangle(iRun,:),yTriangle(iRun,:),'Color',grey,'LineWidth',12);
    
    hCircle(iRun) = annotation('ellipse','Position',[xArrowEnd - circlesize(1)/2,yArrowEnd-circlesize(2)/2, circlesize(1), circlesize(2)*1.5]); %#ok<SAGROW> %y-stretched to maintain circile on expanded fig
    hCircle(iRun).FaceColor=pink;
    hCircle(iRun).Color = pink;

    hText(iRun) = annotation('textbox','Position',[xArrowEnd - circlesize(1)*7/24,yArrowEnd+circlesize(2), 0.015, 0],'FontWeight','bold','Color','w'); %#ok<SAGROW>
    hText(iRun).String = recentruns(iRun);
    hText(iRun).FontSize = tickFontSize*1.8;
    hText(iRun).HorizontalAlignment = 'center';
    hText(iRun).EdgeColor = 'none';
 
    line([iRun; 5],[recentruns(iRun)+1; recentruns(iRun)+1],'LineStyle','-.','LineWidth', 5,'Color',pink);
end

function [xNormalized,yNormalized] = convertDataToNormalizedUnits(a,xData,yData)
    axesPosition = a.Position;
    axesXLimits = a.XLim;
    axesYLimits = a.YLim;
    xNormalized = interp1(axesXLimits,[axesPosition(1) axesPosition(1) + axesPosition(3)],xData);
    yNormalized = interp1(axesYLimits,[axesPosition(2) axesPosition(2) + axesPosition(4)],yData);
end
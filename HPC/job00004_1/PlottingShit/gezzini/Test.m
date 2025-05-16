clc;clearvars; close all;
% Note: the rgb function is used to define more color options.
% it should be within the same folder as the Test.m file, unless you add it
% to the PATH.
SNR = 0:5:20;

C11 = rand(5,1);
C12 = rand(5,1);
C13 = rand(5,1);

C21 = rand(5,1);
C22 = rand(5,1);
C23 = rand(5,1);


C31 = rand(5,1);
C32 = rand(5,1);
C33 = rand(5,1);


X1 = SNR;
YMatrix1 = [C11, C12, C13];


X2 = SNR;
YMatrix2 = [C21, C22, C23];


X3 = SNR;
YMatrix3 = [C31, C32, C33];


Label = 'BER';
YLim_Start = 1;
YLim_end = 0;
Y1Ticks = [0.00001 0.0001 0.001 0.01 0.1 1];

[Figure1] = ThreePlots(X1, YMatrix1, X2, YMatrix2, X3, YMatrix3, YLim_Start,YLim_end,Y1Ticks, Label);
% Save the figure as .eps
% saveas(Figure1,'C:\.. specify the destination path','epsc'); 

function [figure1] = ThreePlots(X1, YMatrix1, X2, YMatrix2, X3, YMatrix3, YLim_Start, YLim_end,Y1Ticks, Label)
%% Create figure
figure1 = figure;
% set the position and size of the figure
figH = 360;
figW = 900;
figY = 200;
figX = 300;
figure1.Position = [figX figY figW figH];
% Create axes 
% ax width and length
axW = 0.27;
axH = 0.7;
axY = 0.14; 
% for horizontal distribution 
axX1 = 0.06;
axX2 = 0.38;
axX3 = 0.70;
%% Left axes 
%% Left axes 
% Setting using properties
axes1 = axes('Parent',figure1); % Axes is added to the figure
axes1.Position = [axX1 axY axW axH];
hold(axes1,'on');
axes1.XLim = [min(X1) max(X1)];
axes1.YLim = [YLim_end YLim_Start];
axes1.YTick = Y1Ticks;
axes1.YScale = 'log';
axes1.Box = 'on';
axes1.XGrid = 'on';
axes1.YGrid = 'on';
ylabel(axes1, Label,'FontSize',12, 'Interpreter','latex');
% to get the bounding coordinates of the axes
axes1.YLim ;
axes1.XLim ;
% Position with respect to the coordinate 

% Create xlabel
% xl1 = xlabel(axes1,'SNR(dB)','FontSize',12,'Interpreter','latex');
% Add plotes to the axes
plot1 = semilogy(X1,YMatrix1,'Parent',axes1);
% set plots styles
set(plot1(1),'LineStyle','-','Marker','o','Color','k','LineWidth',2); % Ideal
set(plot1(2),'LineStyle','-','Marker','^','Color','g','LineWidth',2); % STA
set(plot1(3),'LineStyle',':','Marker','p','Color', rgb('DarkSlateGrey'),'LineWidth',2); % 1D-LMMSE


%% Create roght axes axes2: shorter style
axes2 = axes('Parent',figure1, 'Position',[axX2 axY axW axH]);
hold(axes2,'on');
box(axes2,'on');
grid(axes2,'on');
axes2.YScale = 'log';
axes2.XLim = [min(X2) max(X2)];
% axes2.YLim = [10^-05 10^(-0.5)];
axes2.YLim = [YLim_end YLim_Start];
axes2.YTick = Y1Ticks;
% Create ylabel
axes2.YLim ;
axes2.XLim ;
% ylabel(axes2, Label,'FontSize',12,'Interpreter','latex');

% Create multiple lines using matrix input to plot
plot2 = semilogy(X2,YMatrix2,'Parent',axes2,'LineWidth',1.5);

set(plot2(1),'LineStyle','-','Marker','o','Color','k','LineWidth',2); % Ideal
set(plot2(2),'LineStyle','-','Marker','^','Color','g','LineWidth',2); % STA
set(plot2(3),'LineStyle',':','Marker','p','Color', rgb('DarkSlateGrey'),'LineWidth',2); % 1D-LMMSE




%% Create roght axes axes3: shorter style
axes3 = axes('Parent',figure1, 'Position',[axX3 axY axW axH]);
hold(axes3,'on');
box(axes3,'on');
grid(axes3,'on');
axes3.YScale = 'log';
axes3.XLim = [min(X3) max(X3)];
axes3.YLim = [YLim_end YLim_Start];
axes3.YTick = Y1Ticks;
% Create ylabel
axes3.YLim ;
axes3.XLim ;
% ylabel(axes3,Label,'FontSize',12,'Interpreter','latex');

% Create multiple lines using matrix input to plot
plot3 = semilogy(X3,YMatrix3,'Parent',axes3,'LineWidth',1.5);

set(plot3(1),'LineStyle','-','Marker','o','Color','k','LineWidth',2); % Ideal
set(plot3(2),'LineStyle','-','Marker','^','Color','g','LineWidth',2); % STA
set(plot3(3),'LineStyle',':','Marker','p','Color', rgb('DarkSlateGrey'),'LineWidth',2); % 1D-LMMSE


%% Create legend
p3 = plot1(3);

legend1 = legend(axes1,'show',{'C1','C2'});
legend2 = legend(axes2,[p3],'C3');

legW = 0.46;
legH = 0.08;
LegY = 0.92;
LegX = 0.5-legW/2;
LegY2 = 0.845;
LegX2 = 0.5-legW/2;
set(legend1,...
    'Position',[LegX    LegY    legW    legH],...
     'Orientation','horizontal',...
    'Interpreter','latex',...
    'FontSize',12);

set(legend2,...
    'Position',[LegX2    LegY2    legW    legH],...
    'Orientation','horizontal',...
    'Interpreter','latex',...
    'FontSize',12);

end






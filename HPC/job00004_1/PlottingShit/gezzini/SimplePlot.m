EbN0dB = [0,1,2,3,4,5];
ERR_Initial = [2,3,4,5,6,5];
ERR_TRFI = [4,5,6,7,8,9];
figure,
p1 = semilogy(EbN0dB,ERR_Initial,'r-^','LineWidth',2);
hold on;
p2 = semilogy(EbN0dB,ERR_TRFI,'c-d','LineWidth',2);
grid on;
legend([p1(1),p2(1)],{'DPA','TRFI'},'Orientation','horizontal',...
     'Interpreter','latex',...
     'FontSize',12);
xaxisproperties = get(gca, 'XAxis');
xaxisproperties.TickLabelInterpreter = 'latex';
xaxisproperties.FontSize = 15;
yaxisproperties= get(gca, 'YAxis');
yaxisproperties.TickLabelInterpreter = 'latex';
yaxisproperties.FontSize = 15;

xlabel('SNR(dB)','Interpreter','latex');
ylabel('Normalized Mean Sqaure Error (NMSE)','Interpreter','latex');


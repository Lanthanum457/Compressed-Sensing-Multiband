
function formatMyFigure(varargin)
if length(varargin) == 1
    size = varargin{1};
else
    size = 20;
end
xaxisproperties = get(gca, 'XAxis');
xaxisproperties.TickLabelInterpreter = 'latex';
xaxisproperties.FontSize = size;
yaxisproperties= get(gca, 'YAxis');
yaxisproperties.TickLabelInterpreter = 'latex';
yaxisproperties.FontSize = size;
zaxisproperties= get(gca, 'ZAxis');
zaxisproperties.TickLabelInterpreter = 'latex';
zaxisproperties.FontSize = size;
titleproperties= get(gca, 'Title');
titleproperties.FontSize = size;
colorbarproperties = get(gca,'Colorbar');
colorbarproperties.TickLabelInterpreter = 'latex';
colorbarproperties.FontSize = size;

end

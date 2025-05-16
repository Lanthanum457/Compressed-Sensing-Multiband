
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

end

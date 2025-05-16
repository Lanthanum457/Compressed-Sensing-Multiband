function t_areaPlot
% Generate an area plot using the default plotlab recipe.
%
% Syntax:
%   t_lineMarkerPlot
%
% Description:
%    Demonstrates how to generate an area plot using the default plotlab
%    recipe only overriding the ccolorOrder and figure size). 
%
% Inputs:
%    None.
%
% Outputs:
%    None.
%
% Optional key/value pairs:
%    None.
%

% History:
%    03/21/20  NPC  Wrote it

     % Get the demo data to plot
    [L_absorbance, M_absorbance, S_absorbance, lambda] = getData();
    
    % Colors for the L-, M-, and S-cone nomograms
    LMSconeColors = [...
        1.0 0.2 0.4; ...
        0.1 1.0 0.4; ...
        0.5 0.1 0.8];
            
    % Instantiate a plotlab object
    plotlabOBJ = plotlab();
    
    % Apply the default plotlab recipe overriding 
    % the color order and the figure size
    plotlabOBJ.applyRecipe(...
        'colorOrder', LMSconeColors, ...
        'figureWidthInches', 5, ...
        'figureHeightInches', 5);
    
    % New figure
    hFig = figure(1); clf; hold on;

    % Area plots filled with the LMSconeColors
    % The first area plot is filled with the first LMSconeColor, 
    % the second plot with the second etc. 
    minAbsorbance = 0.01;
    area(lambda, L_absorbance, minAbsorbance);
    area(lambda, M_absorbance, minAbsorbance);
    area(lambda, S_absorbance, minAbsorbance);
    
    % Axes limits and ticks 
    set(gca, 'XLim', [400 700], 'XTick', 350:50:850, ...
        'YLim', [minAbsorbance 1.0], 'YTick', [0.01 0.03 0.1 0.3 1], ...
        'YScale', 'log');
    
    % Labels
    xlabel('\it wavelength (nm)'); ylabel('\it normalized absorbance');

    % Legend
    lHandle = legend({'L', 'M', 'S'});
    
    % Reposition the legend
    plotlabOBJ.repositionLegend(lHandle, [0.78 0.77]);
    
    % Title
    title(sprintf('Stockman-Sharpe cone nomograms'));

    % Export the figure to the gallery directory in PNG format
    plotlabOBJ.exportFig(hFig, 'png', 'SSnomograms', 'gallery');
end

function [L_absorbance, M_absorbance, S_absorbance, lambda] = getData()
    load('nomograms.mat', 'L_absorbance', 'M_absorbance', 'S_absorbance', 'lambda');
end
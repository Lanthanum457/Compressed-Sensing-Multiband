addpath('./PlottingShit/')
addpath('./PlottingShit/matlab2tikz-master/')
addpath('./PlottingShit/matlab2tikz-master/src/')
addpath('./PlottingShit/legendflex-pkg-master/legendflex/')
addpath('./PlottingShit/legendflex-pkg-master/setgetpos_V1.2/')
addpath('./PlottingShit/ZoomPlot-MATLAB-main/')
addpath('./PlottingShit/arrow/')
addpath('./PlottingShit/linspecer/')
addpath('./ADMM/')

%addpath('./plotlab-master/')

bypassLoadingDataEn  = 0; % use to bypass loading data
saveFigEn            = 0; % use to save figure

plotSpecificPointsEn = 1;
saveFigTexEn = 1;
zoomPlotEn = 0;
choosePlotEn = 0;
BatchEn = 0;
close all
clear legendInfo LL legendInfo
clear invisible_*

clc

mainDir = ['./results/'];
clc

jobName = ['job00004_1'];
plotSpecificPointsEn = 0; noOfMs = 4; figIndex = 1; q = 2; MarkerSizePt = 14; LineWidthPt = 2; LegendFontSizePt = 12;   % MSE vs SNR
% jobName = ['my_job_name_goes_here'];

%% Parsing

if bypassLoadingDataEn == 1

else

    %     try
    %% Verify if data is good
    % grab data from first point
    if size(jobName,1) == 1
        dirPath = [mainDir,jobName];
        points  = dir(dirPath);
        for n_points = 3:length(points)
            point_name = points(n_points).name;
            keyterms = split(point_name,'_');
            if (mod(length(keyterms),2) ~= 0)
                error('Data not parsed properly ..')
            end
        end
        %% Initialization of first point
        point_name = points(3).name;
        if strcmp(points(3).name(end-3:end),'.mat')
            point_name = point_name(1:end-4); % remove .mat
        end
        try
            S = load([points(3).folder,'/',points(3).name]);
        catch
            S = load([points(3).folder,'/',points(3).name],'-mat');
        end
        keyterms = split(point_name,'_');
        % inputs
        for k = 1:2:length(keyterms)
            eval([keyterms{k},'=',keyterms{k+1},';'])
        end
        % outputs
        outputs = fieldnames(S);

        for k = 1:length(outputs)
            if size(S.(outputs{k}),1) > 1 || size(S.(outputs{k}),2) > 1
                S.(outputs{k}) = {S.(outputs{k})};
            end
        end


        for k = 1:length(outputs)
            if contains(outputs{k},'cell')
                S.(outputs{k}) = cell2mat(S.(outputs{k})(K(end)));
            end
            eval([outputs{k},'=','S.(','outputs{',num2str(k),'})',';']);
        end
        %% Stack variables
        if BatchEn
            BatchSize = floor(length(points)/noOfBatches);
            rangeOfPoints = [(3+1):(3+1+BatchSize)] + (batchIndex-1)*BatchSize;
        else
            rangeOfPoints = [(3+1):length(points)];
        end

        for n_points = rangeOfPoints

            clc
            disp(['Processing point no. ',num2str(n_points),'/',num2str(length(points))])
            point_name = points(n_points).name;
            if strcmp(points(n_points).name(end-3:end),'.mat')
                point_name = point_name(1:end-4); % remove .mat
            end
            try
                S = load([points(n_points).folder,'/',points(n_points).name]);
            catch
                S = load([points(n_points).folder,'/',points(n_points).name],'-mat');
            end
            if isempty(S) == 1
                S = load([points(n_points).folder,'/',points(n_points).name],'-mat');
            end
            keyterms = split(point_name,'_');
            % inputs
            for k = 1:2:length(keyterms)
                eval([keyterms{k},'= [' ,keyterms{k},'; ', keyterms{k+1},'];']);
            end
            % outputs
            outputs = fieldnames(S);
            for k = 1:length(outputs)
                if contains(outputs{k},'cell')
                    S.(outputs{k}) = cell2mat(S.(outputs{k})(K(end)));
                end
                eval([outputs{k},'=[',outputs{k},'; ','S.(','outputs{',num2str(k),'})','];']);
            end
        end

        n_points = length(rangeOfPoints);

        createTableExpression = 'T = table(';
        for k = 1:2:length(keyterms)
            createTableExpression = [createTableExpression,keyterms{k},','];
        end
        for k = 1:length(outputs)
            createTableExpression = [createTableExpression,outputs{k},','];
        end
        createTableExpression = createTableExpression(1:end-1);
        createTableExpression = [createTableExpression,')'];
        eval(createTableExpression)
    else
        [T] = createMyTables(mainDir,jobName);
    end


    %
    %     catch
    %         warning('This job can not load tables ..')
    %     end
end
lineStyle={'-','--','-.',':'};
markerStyle = {'x','^','s','*','o','p'};
markerStyle1 = {'x','o','^','s'};
% colors = [043 048 122;
%     119 194 243;
% %    247 238 246;
%     216 160 199;
%     169 111 176]/255;           % Colors for visualization
% colormap = matColorMap(colors,1000);
% coloridxes = [1 250 500 750 999];
% colors = colormap(coloridxes,:);
colors = linspecer(12,'seq');



%% Plot my data


mc_vals = unique(T.mc).';
fa_vals = unique(T.fa).';
npaths_vals = unique(T.npaths).';
PT_vals = unique(T.PT).';

%% Delay MSE vs PT (for different fa - cs only)

if 1

    n_legend=1;

    for fa = fa_vals
        HRMSE_CS = Inf*ones(1,length(PT_vals));
        i = 1;
        for PT = PT_vals
            E_CS_perPT = 0;
            j = 0;
            for mc = mc_vals
                pointsToPlot = find((T.mc == mc) & ...
                    (T.fa == fa) & ...
                    (T.npaths == npaths_vals(1))& ...
                    (T.PT == PT)).';
                if ~isempty(pointsToPlot) 
                    j = j+1; 
                    E_CS_perPT = E_CS_perPT + T.E_CSdelays(pointsToPlot);
                end
            end
            if ~isempty(E_CS_perPT) E_CS_perPT =  E_CS_perPT/j; else E_CS_perPT = Inf; end

            HRMSE_CS(i) = E_CS_perPT;
            i = i + 1;
        end

        %% legend info
        legendInfo{n_legend}  = [num2str(fa),' GHz Aperture'];
        figure(1)
        semilogy(PT_vals, 1e9*HRMSE_CS ,['o',lineStyle{1}],'Color',colors(n_legend,:),'LineWidth',LineWidthPt,'MarkerSize',MarkerSizePt);hold on;
        n_legend=n_legend+1;

    end

    figure(1)
    xlabel('Transmit Power (dBm)','Interpreter','latex');
    ylabel('Delay H-RMSE (ns)','Interpreter','latex');
    legend(legendInfo,...
        'Interpreter','latex',...
        'FontSize',LegendFontSizePt,...
        'Position',[0.7 0.725 0.145 0.150])
    xlim([-6,30]);
    grid on
    grid minor

    formatMyFigure
  zp = BaseZoom();
    zp.plot;
end

%% Angle MSE vs PT (for different npaths - cs)
if 1

    n_legend=1;

    for fa = fa_vals
        HRMSE_CS = Inf*ones(1,length(PT_vals));
        i = 1;
        for PT = PT_vals
            E_CS_perPT = 0;
            E_BF_perPT = 0;
            j = 0;
            for mc = mc_vals
                pointsToPlot = find((T.mc == mc) & ...
                    (T.fa == fa) & ...
                    (T.npaths == npaths_vals(1))& ...
                    (T.PT == PT)).';
                if ~isempty(pointsToPlot) 
                    j = j+1; 
                    E_CS_perPT = E_CS_perPT + T.E_CSangles(pointsToPlot);
                end
            end
            if ~isempty(E_CS_perPT) E_CS_perPT =  E_CS_perPT/j; else E_CS_perPT = Inf; end

            HRMSE_CS(i) = E_CS_perPT;
            i = i + 1;
        end

        %% legend info
        legendInfo{n_legend}  = [num2str(fa),' GHz Aperture'];
        figure(2)
        semilogy(PT_vals, HRMSE_CS ,['o',lineStyle{1}],'Color',colors(n_legend,:),'LineWidth',LineWidthPt,'MarkerSize',MarkerSizePt);hold on;
        n_legend=n_legend+1;

    end

    figure(2)
    xlabel('Transmit Power (dBm)','Interpreter','latex');
    ylabel('Angle H-RMSE (deg)','Interpreter','latex');
    legend(legendInfo,...
        'Interpreter','latex',...
        'FontSize',LegendFontSizePt,...
        'Position',[0.7 0.725 0.145 0.150])
    xlim([-6,30]);
    grid on
    grid minor


    formatMyFigure
        zp = BaseZoom();
    zp.plot;
end
%% SRP vs PT (for cs for different fa and fixed npaths)
if 1

    n_legend=1;

    for fa = fa_vals
        SRP = Inf*ones(1,length(PT_vals));
        i = 1;
        for PT = PT_vals
            SRP_perPT = 0;
            j = 0;
            for mc = mc_vals
                pointsToPlot = find((T.mc == mc) & ...
                    (T.fa == fa) & ...
                    (T.npaths == npaths_vals(1))& ...
                    (T.PT == PT)).';
                if ~isempty(pointsToPlot) 
                    j = j+1; 
                    SRP_perPT = SRP_perPT + T.SR_CS(pointsToPlot);
                end
            end
            if ~isempty(SRP_perPT) SRP_perPT =  SRP_perPT/j; else SRP_perPT = Inf; end

            SRP(i) = SRP_perPT;
            i = i + 1;
        end

        %% legend info
        legendInfo{n_legend}  = [num2str(fa),' GHz Aperture'];
        figure(3)
        semilogy(PT_vals, SRP ,['o',lineStyle{1}],'Color',colors(n_legend,:),'LineWidth',LineWidthPt,'MarkerSize',MarkerSizePt);hold on;
        n_legend=n_legend+1;

    end

    figure(3)
    xlabel('Transmit Power (dBm)','Interpreter','latex');
    ylabel('SRP','Interpreter','latex');
    legend(legendInfo,...
        'Interpreter','latex',...
        'FontSize',LegendFontSizePt,...
        'Position',[0.2 0.225 0.145 0.150])
    xlim([-6,30]);
    grid on
    grid minor


    formatMyFigure
        zp = BaseZoom();
    zp.plot;
end
%% Mean Gain MSE vs PT (for different npaths - cs)
if 1

    n_legend=1;

    for fa = fa_vals
        HRMSE_CS = Inf*ones(1,length(PT_vals));
        i = 1;
        for PT = PT_vals
            E_CS_perPT = 0;
            E_BF_perPT = 0;
            j = 0;
            for mc = mc_vals
                pointsToPlot = find((T.mc == mc) & ...
                    (T.fa == fa) & ...
                    (T.npaths == npaths_vals(1))& ...
                    (T.PT == PT)).';
                if ~isempty(pointsToPlot) 
                    j = j+1; 
                    cellgains = T.E_CSgains(pointsToPlot);
                    matgains = cellgains{1};
                    E_CS_perPT = E_CS_perPT + mean(matgains);
                end
            end
            if ~isempty(E_CS_perPT) E_CS_perPT =  E_CS_perPT/j; else E_CS_perPT = Inf; end

            HRMSE_CS(i) = E_CS_perPT;
            i = i + 1;
        end

        %% legend info
        legendInfo{n_legend}  = [num2str(fa),' GHz Aperture'];
        figure(4)
        plot(PT_vals, HRMSE_CS ,['o',lineStyle{1}],'Color',colors(n_legend,:),'LineWidth',LineWidthPt,'MarkerSize',MarkerSizePt);hold on;
        n_legend=n_legend+1;

    end

    figure(4)
    xlabel('Transmit Power (dBm)','Interpreter','latex');
    ylabel('Average Gains H-RMSE (\%)','Interpreter','latex');
    legend(legendInfo,...
        'Interpreter','latex',...
        'FontSize',LegendFontSizePt,...
        'Position',[0.65 0.2 0.145 0.150])
    xlim([-6,30]);
    grid on
    grid minor

    % zp = BaseZoom();
    % zp.plot;
    formatMyFigure
end
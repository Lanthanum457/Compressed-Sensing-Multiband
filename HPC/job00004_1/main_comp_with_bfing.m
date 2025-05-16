function [E_CSangles,E_CSdelays,SR_CS,E_CSgains,E_BFangles,E_BFdelays,SR_BF] = main_comp_with_bfing(mc,fa,npaths,PT)
%% 1. Initialization
rng(mc); % monte carlo count

numcount_innerloop = 60;
E_CSangles = 0;
E_CSdelays = 0;
SR_CS = 0;
E_CSgains = 0;
E_BFangles = 0;
E_BFdelays = 0;
SR_BF = 0;


for count_innerloop = 1:numcount_innerloop
    c = physconst('lightspeed');
    % System Parameters
    MB_f = [7 7+fa]*1e9;          % Subband frequencies
    Q = 1000;                    % Number of subcarriers
    MB_fb = [200 200] * 1e3;    % Subcarrier spacing
    MB_d = (c./MB_f)./2;            % Antenna spacing
    M = 60;                         % Number of antennas
    K = length(MB_f);               % Number of subbands
    modulation = 4;                 % 4-QAM
    %PT = -10;                         % Transmit power (dBm)
    N0 = -174;                     % Thermal noise power spectral density (dBm)
    NF = 7;                         % Noise figure (dB)

    % Path parameters
    % npaths = 10;
    gains = rand(npaths,K) + 1i * rand(npaths,K);           % DEPENDENT on subband frequency
    delays = round((40 + rand(npaths,1) * 160)) * 1e-9;     % ON-GRID delays between 40 and 200 ns (limit to farfield)
    angles = round(rand(npaths,1) * 180 - 90);              % ON-GRID angles between -90 and 90 deg
    PL = 1./(4*pi*MB_f.*delays).^2;                         % Pathloss

    BW = Q.*MB_fb;

    %% 2. Channel and Signal Generation
    % Initialize Variables
    s = cell(K,1);                              % Pilot symbols
    Y = cell(K,1);                              % Received signal

    % Noise Variance
    noisevar = db2pow(N0+NF) * BW;              % Noise variance per subband (mW)
    noisevar_total = db2pow(N0+NF) * sum(BW);   % Total noise variance (mW)

    for k = 1:K
        fb = MB_fb(k);
        d = MB_d(k);
        f = MB_f(k);

        % Channel Matrix (Hchan)
        Hchan = zeros(M,Q);
        for p = 1:npaths
            a_R = exp(-1i*2*pi*d*f*(0:M-1).'*sind(angles(p))/c); % Rx steering
            a_F = exp(-1i*2*pi*(f+fb*(0:Q-1).')*delays(p)); % Freq steering
            Hchan = Hchan + sqrt(db2pow(PT))*sqrt(PL(p,k)).*gains(p,k).* (a_R*a_F.'); % Outer product
        end

        % Pilot symbols (s)
        s{k} = qammod(randi([0,modulation-1],Q,1),modulation,'UnitAveragePower',true);

        % Received signal (Y)
        W = sqrt(noisevar(k)/2) * (randn(M,Q) + 1i * randn(M,Q));
        Y{k} = Hchan.*s{k}.' + W;
    end


    [CSnpaths_est,CSangles_est,CSdelays_est,CSgains_est] = csadmmsolver(s,Y,MB_f,MB_d,MB_fb,Q,M,K,noisevar_total);


    if CSnpaths_est == 0
        E_CSdelays_percount =sqrt(mean(delays.^2));
        E_CSangles_percount =sqrt(mean(angles.^2));
        E_CSgains_percount = 100;
    else
        CSCostMatrix_delays = abs(delays - CSdelays_est.').^2;
        CSCostMatrix_angles = abs(angles - CSangles_est.').^2;
        CSassdelays = matchpairs(CSCostMatrix_delays,1e10);
        CSassangles = matchpairs(CSCostMatrix_angles,1e10);
        E_CSdelays_percount = sqrt(mean((delays(CSassdelays(:,1)) - CSdelays_est(CSassdelays(:,2))).^2));
        E_CSangles_percount = sqrt(mean((angles(CSassangles(:,1)) - CSangles_est(CSassangles(:,2))).^2));
        gainswPLPT = sqrt(db2pow(PT))*sqrt(PL).*gains;

        HRMSE_gains = zeros(K,1);
        for k = 1:K
            CostMatrix_gains_k = abs(gainswPLPT(:,k) - CSgains_est(:,k).').^2;
            assgains_k = matchpairs(CostMatrix_gains_k,1e10);
            HRMSE_gains(k) = sqrt(mean(abs(gainswPLPT(assgains_k(:,1),k) - CSgains_est(assgains_k(:,2),k)).^2));
        end
        E_CSgains_percount = 100 * HRMSE_gains ./ vecnorm(gainswPLPT(assgains_k(:,1),:),2,1).';
    end

    if CSnpaths_est == npaths &&...
            max(delays(CSassdelays(:,1)) - CSdelays_est(CSassdelays(:,2))) <= 1e-9 &&...
            max(angles(CSassangles(:,1)) - CSangles_est(CSassangles(:,2))) <= 1
        SR_CS_percount = 1;
    else
        SR_CS_percount = 0;
    end



    [BFnpaths_est,BFangles_est,BFdelays_est] = bfingsolver(s,Y,MB_f,MB_d,MB_fb,Q,M,K);

    if BFnpaths_est == 0
        E_BFdelays_percount =sqrt(mean(delays.^2));
        E_BFangles_percount =sqrt(mean(angles.^2));
    else
        BFCostMatrix_delays = abs(delays - BFdelays_est.').^2;
        BFCostMatrix_angles = abs(angles - BFangles_est.').^2;
        BFassdelays = matchpairs(BFCostMatrix_delays,1e10);
        BFassangles = matchpairs(BFCostMatrix_angles,1e10);
        E_BFdelays_percount = sqrt(mean((delays(BFassdelays(:,1)) - BFdelays_est(BFassdelays(:,2))).^2));
        E_BFangles_percount = sqrt(mean((angles(BFassangles(:,1)) - BFangles_est(BFassangles(:,2))).^2));
    end

    if BFnpaths_est == npaths &&...
            max(delays(BFassdelays(:,1)) - BFdelays_est(BFassdelays(:,2))) <= 1e-9 &&...
            max(angles(BFassangles(:,1)) - BFangles_est(BFassangles(:,2))) <= 1
        SR_BF_percount = 1;
    else
        SR_BF_percount = 0;
    end


    E_CSangles = E_CSangles + (1/numcount_innerloop) * E_CSangles_percount;
    E_CSdelays = E_CSdelays + (1/numcount_innerloop) * E_CSdelays_percount;
    SR_CS = SR_CS + (1/numcount_innerloop) * SR_CS_percount;
    E_CSgains = E_CSgains + (1/numcount_innerloop) * E_CSgains_percount;
    E_BFangles = E_BFangles + (1/numcount_innerloop) * E_BFangles_percount;
    E_BFdelays = E_BFdelays + (1/numcount_innerloop) * E_BFdelays_percount;
    SR_BF = SR_BF + (1/numcount_innerloop) * SR_BF_percount;
end









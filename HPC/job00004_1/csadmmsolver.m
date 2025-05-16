function [CSnpaths_est,CSangles_est,CSdelays_est,CSgains_est] = csadmmsolver(s,Y,MB_f,MB_d,MB_fb,Q,M,K,noisevar_total)

c = physconst('lightspeed');
BW = Q.*MB_fb;

% ADMM Parameters
max_iter = 1000;                    % Max ADMM iterations
rho_init = 1;                       % Initial ADMM penalty parameter
alpha = 1;                          % Step size scaling
tol_abs = 1e-8;                     % Absolute tolerance
tol_rel = 1e-8;                     % Relative tolerance
anglegrid_cs = (-90:1:90).';        % Angle grid
delaygrid_cs = (0:1:200).'*1e-9;    % Delay grid
L_angle = length(anglegrid_cs);
L_delay = length(delaygrid_cs);

% Adaptive parameter constants
mu_incr = 1000;                         % Balance factor for primal and dual residuals
mu_decr = 0.001;
tau_incr = 1.1111;                       % Rho increase factor
tau_decr = 0.9000;                     % Rho decrease factor
rho_check_interval = 5;            % Check residual balance every N iterations
rho_min = 1e-5;                     % Minimum allowed rho value
rho_max = 1e5;                       % Maximum allowed rho value

% Compute Dictonaries
for k = 1:K
    fb = MB_fb(k);
    d = MB_d(k);
    f = MB_f(k);
    % Delay Dictionary (A1)
    A1{k} = zeros(Q, L_delay);
    for i = 1:L_delay
        A1{k}(:,i) = s{k} .* exp(-1i*2*pi*(f+fb*(0:Q-1).')*delaygrid_cs(i));
    end

    % Angle Dictionary (A2)
    A2{k} = zeros(M, L_angle);
    for i = 1:L_angle
        A2{k}(:,i) = exp(-1i*2*pi*d*(0:M-1).'*f*sind(anglegrid_cs(i))/c);
    end

    % Calculate matrix norms for step size calculation
    norm_A2 = norm(A2{k}, 2);
    norm_A1 = norm(A1{k}, 2);
    norm_A_full(k) = norm_A1 * norm_A2;
    A_norms{k} = [norm_A1, norm_A2];
end

% Initialize constraint bound using actual noise variance
epsilon_total = 1.2*sqrt(M*Q*noisevar_total);           % Initial constraint bound
epsilon = epsilon_total.*sqrt(BW./sum(BW));             % Per-subband constraint

% Initialize variables
HH = zeros(L_delay*L_angle, K);    % Matrix to optimize
Z = cell(K,1);                      % Auxiliary variables
U = cell(K,1);                      % Dual variables
rho = rho_init * ones(K,1);         % Per-subband penalty parameter

% Initialize gamma (step size) for each subband
gamma = alpha / max(rho.*norm_A_full.^2,[],'all');

% Initialize Z and U
for k = 1:K
    Z{k} = zeros(M,Q);    % Initialize Z_k
    U{k} = zeros(M,Q);    % Initialize U_k
end

% ADMM iterations
for iter = 1:max_iter
    % For checking convergence
    Z_prev = Z;
    primal_res_k = zeros(K,1);
    dual_res_k = zeros(K,1);

    % Update HH using proximal gradient step
    G = zeros(size(HH));
    for k = 1:K
        % Compute A_full,k * h_k efficiently
        h_k = HH(:,k);
        h_k_mat = reshape(h_k, [L_angle, L_delay]);
        AhA = A2{k} * h_k_mat * A1{k}.';

        % Gradient computation
        res_mat = AhA - (Z{k} - U{k});
        grad_mat = A2{k}' * res_mat * conj(A1{k}); % A1 is conjugated in dictionary
        G(:,k) = rho(k) * grad_mat(:);
    end

    HH_temp = HH - gamma * G;

    % Apply proximal operator (row-wise group soft-thresholding)
    rownorms = vecnorm(HH_temp, 2, 2);
    HH = max(0,1 - gamma./rownorms) .* HH_temp;

    % Update Z (auxiliary variables) with ADMM projection step
    for k = 1:K
        % Reshape HH to matrix form for efficient computation
        h_k_mat = reshape(HH(:,k), [L_angle, L_delay]);
        AhA = A2{k} * h_k_mat * A1{k}.';

        % Update Z with proximal operator (projection onto l2 ball)
        Z_tilde = AhA + U{k};
        Y_k = Y{k};

        % Calculate residual
        R = Z_tilde - Y_k;
        R_norm = norm(R, 'fro');

        % Projection onto epsilon-radius ball
        if R_norm > epsilon(k)
            Z{k} = Y_k + epsilon(k) * R / R_norm;
        else
            Z{k} = Z_tilde;
        end

        % Update residuals for convergence check
        primal_res_k(k) = norm(AhA - Z{k}, 'fro');
        dual_res_k(k) = rho(k) * norm(Z{k} - Z_prev{k}, 'fro');
    end

    % Update dual variables U
    for k = 1:K
        h_k_mat = reshape(HH(:,k), [L_angle, L_delay]);
        AhA = A2{k} * h_k_mat * A1{k}.';
        U{k} = U{k} + (AhA - Z{k});
    end


    % Adaptive rho update (every rho_check_interval iterations)
    if mod(iter, rho_check_interval) == 0
        for k = 1:K
            % Balance primal and dual residuals
            if primal_res_k(k) > mu_incr * dual_res_k(k)
                % Primal residual too large - increase penalty
                rho(k) = min(rho_max, rho(k) * tau_incr);
                U{k} = U{k} / tau_incr;  % Rescale dual variable
            elseif dual_res_k(k) > mu_decr * primal_res_k(k)
                % Dual residual too large - decrease penalty
                rho(k) = max(rho_min, rho(k) * tau_decr);
                U{k} = U{k} / tau_decr;  % Rescale dual variable
            end
        end
        gamma = alpha / max(rho.*norm_A_full.^2,[],'all');
    end

    % Add termination criteria based on residuals
    % Primal tolerance
    max_norm_Z = max(cellfun(@(Z) norm(Z,'fro'), Z));
    max_norm_AhA = zeros(K,1);
    for k = 1:K
        h_k_mat = reshape(HH(:,k), [L_angle, L_delay]);
        AhA = A2{k} * h_k_mat * A1{k}.';
        max_norm_AhA(k) = norm(AhA, 'fro');
    end
    max_norm_AhA = max(max_norm_AhA);
    tol_primal = tol_abs * sqrt(numel(Z{1})) + tol_rel * max(max_norm_AhA, max_norm_Z);

    % Dual tolerance
    max_norm_U = max(cellfun(@(U,r) norm(r * U,'fro'), U, num2cell(rho)));
    tol_dual = tol_abs * sqrt(numel(Z{1})) + tol_rel * max_norm_U;

    % Overall residuals for convergence
    primal_res = mean(primal_res_k);
    dual_res = mean(dual_res_k);


    % Check termination
    if  dual_res < tol_dual
        break;
    end
end

Hestmag = reshape(mean(abs(HH),2), [L_angle, L_delay]);
Hestmag_norm = Hestmag / max(Hestmag,[],'all');

% Peakfinding
threshold = 0.05;
[pks,locs_angle,locs_delay] = peaks2(max(threshold,Hestmag_norm));
CSdelays_est = delaygrid_cs(locs_delay);
CSangles_est = anglegrid_cs(locs_angle);
CSnpaths_est = length(pks);

% Estimate Gains (skip if no paths are estimated)
CSgains_est = zeros(CSnpaths_est,K);
if CSnpaths_est ~= 0
    for k = 1:K
        % Construct reduced full dictionary D
        D = [];
        for nhat = 1:CSnpaths_est
            a1 = A1{k}(:, locs_delay(nhat));
            a2 = A2{k}(:, locs_angle(nhat));
            D(:,nhat) = kron(a1,a2);
        end
        CSgains_est(:,k) = pinv(D)*Y{k}(:);
    end
end
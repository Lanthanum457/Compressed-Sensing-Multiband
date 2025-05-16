function [BFnpaths_est,BFangles_est,BFdelays_est] = bfingsolver(s,Y,MB_f,MB_d,MB_fb,Q,M,K)
c = physconst('lightspeed');
anglegrid = (-90:1:90).';        % Angle grid
delaygrid = (0:1:200).'*1e-9;    % Delay grid
L_angle = length(anglegrid);
L_delay = length(delaygrid);

P = zeros(L_angle,L_delay);
for k = 1:K
    fb = MB_fb(k);
    d = MB_d(k);
    f = MB_f(k);
    for theta_idx = 1:length(anglegrid)
        theta = anglegrid(theta_idx);
        a_theta = exp(-1i*2*pi*d*f*(0:M-1).'*sind(theta)/c);
        for tau_idx = 1:length(delaygrid)
            tau = delaygrid(tau_idx);
            a_tau = exp(-1i*2*pi*(f+fb*(0:Q-1).')*tau);
            P(theta_idx,tau_idx) = P(theta_idx,tau_idx) + (1/K) * abs((s{k}.*a_tau).'*Y{k}'*a_theta);
        end
    end
end
P_norm = P/max(P,[],'all'); % Normalization

% Peakfinding
threshold = 0.15;
[pks,locs_angle,locs_delay] = peaks2(max(threshold,P_norm));
BFdelays_est = delaygrid(locs_delay);
BFangles_est = anglegrid(locs_angle);
BFnpaths_est = length(pks);
function[] = job00004_1(mc,fa,npaths,PT)
%% ADMM - Sim05 - SER
warning('off')

    %% Init
    rng(1)
    %rng('shuffle')
    nameDir = ['./results/','jobs/',mfilename];
    mkdir(nameDir)

    [E_CSangles,E_CSdelays,SR_CS,E_CSgains,E_BFangles,E_BFdelays,SR_BF] = main_comp_with_bfing(mc,fa,npaths,PT);
    %% INPUT
    additional_info = ['mc_',num2str(mc),...
                      '_fa_',num2str(fa),...
                      '_npaths_',num2str(npaths),...
                      '_PT_',num2str(PT)];

    additional_info=[additional_info,'.mat'];
    %,... '_thetaRIS2PR_',num2str(theta_RIS_PR),...'_thetaAP2PR_',num2str(theta_AP_PR),...'.mat'];
    %% OUTPUT
    save([nameDir,'/',additional_info],'E_CSangles',...
                                       'E_CSdelays',...
                                       'SR_CS',...
                                       'E_CSgains',...
                                       'E_BFangles',...
                                       'E_BFdelays',...
                                       'SR_BF');
end




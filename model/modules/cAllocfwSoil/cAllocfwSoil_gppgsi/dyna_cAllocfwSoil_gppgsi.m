function [f,fe,fx,s,d,p] = dyna_cAllocfwSoil_gppgsi(f,fe,fx,s,d,p,info,tix)
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % compute the moisture effect on C allocation computed from GSI approach.
    %
    % Inputs:
    %   - d.prev.d_cAllocfwSoil_fW:    previous moisture stressor value
    %   - d.gppfwSoil.SMScGPP:         moisture stressors on GPP
    %   - p.cAllocfwSoil.tau:          parameter for turnover times
    %
    % Outputs:
    %   - d.cAllocfwSoil.fW:           values for the moisture effect
    %                                  on decomposition/mineralization
    %
    % Modifies:
    %   - d.cAllocfwSoil.fW
    %
    % References:
    %   - Jolly, William M., Ramakrishna Nemani, and Steven W. Running. "A generalized, bioclimatic index to predict foliar phenology in response to climate." Global Change Biology 11.4 (2005): 619-632.
    %   - Forkel M, Carvalhais N, Schaphoff S, von Bloh W, Migliavacca M, Thurner M, Thonicke K (2014) Identifying environmental controls on vegetation greenness phenology through model–data integration. Biogeosciences, 11, 7025–7050.
    %   - Forkel, M., Migliavacca, M., Thonicke, K., Reichstein, M., Schaphoff, S., Weber, U., Carvalhais, N. (2015).
    %     Codominant water control on global interannual variability and trends in land surface phenology and greenness.
    %
    % Created by:
    %   - ncarvalhais and sbesnard
    %
    % Versions:
    %   - 1.0 on 12.01.2020 (sbesnard)
    %
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    % computation for the moisture effect on decomposition/mineralization
    pfW = d.prev.d_cAllocfwSoil_fW;
    d.cAllocfwSoil.fW(:, tix) = pfW + (d.gppfwSoil.SMScGPP(:, tix) - pfW) .* p.cAllocfwSoil.tau_wSoil;
end

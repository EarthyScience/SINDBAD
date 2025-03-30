function [f,fe,fx,s,d,p] = dyna_cAllocfRad_gsi(f,fe,fx,s,d,p,info,tix)
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % computation for the radiation effect on decomposition/mineralization using
    % a GSI method
    % Inputs:
    %   - d.prev.d_cAllocfRad_fR:   previous values for the radiation effect on decomposition/mineralization
    %   - f.PAR:                    values for PAR
    %   - p.cAllocfRad.slope:
    %   - p.cAllocfRad.tau:
    %   - p.cAllocfRad.base:
    %
    % Outputs:
    %   - d.cAllocfRad.fR: values for the radiation effect on decomposition/mineralization
    %
    % Modifies:
    %   - d.cAllocfRad.fR
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

    % computation for the radiation effect on decomposition/mineralization
    pfR = d.prev.d_cAllocfRad_fR;
    fR = (1 ./ (1 + exp(-p.cAllocfRad.slope_Rad .* (f.PAR(:, tix) - p.cAllocfRad.base_Rad))));
    d.cAllocfRad.fR(:, tix) = pfR + (fR - pfR) .* p.cAllocfRad.tau_Rad;
end

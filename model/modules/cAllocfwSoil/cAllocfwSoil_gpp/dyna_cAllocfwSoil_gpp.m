function [f,fe,fx,s,d,p] = dyna_cAllocfwSoil_gpp(f,fe,fx,s,d,p,info,tix)
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % set the moisture effect on C allocation to the same as gpp from GSI approach.
    %
    % Inputs:
    %   - d.gppfwSoil.SMScGPP:         moisture stressors on GPP
    %
    % Outputs:
    %   - d.cAllocfwSoil.fW:           values for the moisture effect
    %                                  on decomposition/mineralization
    %
    % Modifies:
    %   - d.cAllocfwSoil.fW
    %
    % References:
    %
    % Created by:
    %   - skoirala
    %
    % Versions:
    %   - 1.0 on 26.01.2021 (skoirala)
    %
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    % computation for the moisture effect on decomposition/mineralization
    d.cAllocfwSoil.fW(:, tix) = d.gppfwSoil.SMScGPP(:, tix);
end

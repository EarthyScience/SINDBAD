function [f,fe,fx,s,d,p] = dyna_cAllocfRad_gpp(f,fe,fx,s,d,p,info,tix)
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % computation for the radiation effect on decomposition/mineralization as the same for GPP
    %
    % Inputs:
    %   - d.gppfRdiff.CloudScGPP(:,tix): light scalar for GPP
    %
    % Outputs:
    %   - d.cAllocfRad.fR: values for the radiation effect on decomposition/mineralization
    %
    % Modifies:
    %   - d.cAllocfRad.fR
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

    % computation for the radiation effect on decomposition/mineralization
    d.cAllocfRad.fR(:, tix) = d.gppfRdiff.CloudScGPP(:,tix);
end

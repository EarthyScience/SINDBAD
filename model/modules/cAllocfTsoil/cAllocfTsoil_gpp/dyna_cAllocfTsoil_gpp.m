function [f,fe,fx,s,d,p] = dyna_cAllocfTsoil_gpp(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % compute the temperature effect on C allocation to the same as gpp.
    %
    % Inputs:
    %   - d.gppfTair.TempScGPP:        temperature stressors on GPP 
    %
    % Outputs:
    %   - d.cAllocfTsoil.fT: values for the temperature effect on decomposition/mineralization 
    %
    % Modifies:
    %   - 
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

    % computation for the temperature effect on decomposition/mineralization
    d.cAllocfTsoil.fT(:,tix) =   d.gppfTair.TempScGPP(:,tix);
end

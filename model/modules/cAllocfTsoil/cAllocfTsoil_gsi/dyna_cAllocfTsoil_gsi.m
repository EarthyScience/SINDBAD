function [f,fe,fx,s,d,p] = dyna_cAllocfTsoil_gsi(f,fe,fx,s,d,p,info,tix)
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % compute the temperature effect on C allocation based on GSI approach.
    %
    % Inputs:
    %   - d.prev.d_cAllocfTsoil_fT:    previous temperature stressor value
    %   - d.gppfTair.TempScGPP:        temperature stressors on GPP 
    %   - p.cAllocfTsoil.tau:       
    %
    % Outputs:
    %   - d.cAllocfTsoil.fT: values for the temperature effect on decomposition/mineralization 
    %
    % Modifies:
    %   - d.cAllocfTsoil.fT
    %
    % References:
    %   -  
    %
    % Created by:
    %   - ncarvalhais and sbesnard 
    %
    % Versions:
    %   - 1.0 on 12.01.2020 (sbesnard)
    %
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    % computation for the temperature effect on decomposition/mineralization
    pfT = d.prev.d_cAllocfTsoil_fT;
    d.cAllocfTsoil.fT(:,tix) =   pfT +(d.gppfTair.TempScGPP(:,tix)-pfT).*p.cAllocfTsoil.tau;
end
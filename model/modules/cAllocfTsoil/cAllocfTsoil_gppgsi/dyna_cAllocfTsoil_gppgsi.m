function [f,fe,fx,s,d,p] = dyna_cAllocfTsoil_gppgsi(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % compute the temperature effect on C allocation based on GSI approach.
    %
    % Inputs:
    %   - d.prev.d_cAllocfTsoil_fT:    previous temperature stressor value
    %   - d.gppfTair.TempScGPP:        temperature stressors on GPP 
    %   - p.cAllocfTsoil.tau:          temporal change rate for the light-limiting function
    %
    % Outputs:
    %   - d.cAllocfTsoil.fT: values for the temperature effect on decomposition/mineralization 
    %
    % Modifies:
    %   - 
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

    % computation for the temperature effect on decomposition/mineralization
    pfT = d.prev.d_cAllocfTsoil_fT;
    d.cAllocfTsoil.fT(:,tix) =   pfT + (d.gppfTair.TempScGPP(:,tix) - pfT) .* p.cAllocfTsoil.tau_Tsoil;
end

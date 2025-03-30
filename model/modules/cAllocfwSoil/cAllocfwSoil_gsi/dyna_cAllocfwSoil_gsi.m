function [f,fe,fx,s,d,p] = dyna_cAllocfwSoil_gsi(f,fe,fx,s,d,p,info,tix)
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % compute the moisture effect on C allocation computed from GSI approach.
    %
    % Inputs:
    %   - d.prev.d_cAllocfwSoil_fW:    previous moisture stressor value
    %   - d.gppfwSoil.SMScGPP:         moisture stressors on GPP 
    %   - p.cAllocfwSoil.tau:       
    %
    % Outputs:
    %   - d.cAllocfwSoil.fW: values for the moisture effect on decomposition/mineralization 
    %
    % Modifies:
    %   - d.cAllocfwSoil.fW
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

    % computation for the moisture effect on decomposition/mineralization
    pfW                       = d.prev.d_cAllocfwSoil_fW;
    d.cAllocfwSoil.fW(:,tix) =  pfW+(d.gppfwSoil.SMScGPP(:,tix)-pfW).*p.cAllocfwSoil.tau;
end
function [f,fe,fx,s,d,p] = dyna_cAllocfRad_gsi(f,fe,fx,s,d,p,info,tix)
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % computation for the radiation effect on decomposition/mineralization using 
    % a GSI method
    % Inputs:
    %   - d.prev.d_cAllocfRad_fR:   previous values for the radiation effect on decomposition/mineralization            values for potential evapotranspiration
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
    %   -  
    %
    % Created by:
    %   - ncarvalhais and sbesnard 
    %
    % Versions:
    %   - 1.0 on 12.01.2020 (sbesnard)
    %
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    % computation for the radiation effect on decomposition/mineralization
    pfR                       = d.prev.d_cAllocfRad_fR;
    fR                        = (1./(1+exp(-p.cAllocfRad.slope.*(f.PAR(:,tix)-p.cAllocfRad.base))));
    d.cAllocfRad.fR(:,tix) =  pfR+(fR-pfR).*p.cAllocfRad.tau;
end
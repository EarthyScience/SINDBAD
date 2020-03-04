function [f,fe,fx,s,d,p] = prec_cAllocfTsoil_Friedlingstein1999(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % Compute partial computation for the temperature effect on
    % decomposition/mineralization
    %
    % Inputs:
    %   - fe.cTaufTsoil.fT:          values for effect of temperature on soil decomposition
    %   - p.cAllocfTsoil.maxL_fT:    maximum limitation for the temperature function (for pseudo Nutrient Limitation estimations) 
    %   - p.cAllocfTsoil.minL_fT:    minimum limitation for the temperature function (for pseudo Nutrient Limitation estimations)                
    %
    % Outputs:
    %   - fe.cAllocfTsoil.NL_fT:     values for temperature stressor on C allocation  
    %
    % Modifies:
    %   - fe.cAllocfTsoil.NL_fT
    %
    % References:
    %   -  Friedlingstein, P., G. Joel, C.B. Field, and I.Y. Fung, 1999: Toward an allocation scheme for global terrestrial carbon models. Glob. Change Biol., 5, 755-770, doi:10.1046/j.1365-2486.1999.00269.x.
    %
    % Created by:
    %   - ncarvalhais 
    %
    % Versions:
    %   - 1.0 on 12.01.2020 (sbesnard)
    %
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% Compute partial computation for the temperature effect on
% decomposition/mineralization
NL_fT                                 	= fe.cTaufTsoil.fT;
%sujan the right hand side of equation below has p which has one value but
%LHS is nPix,nTix
NL_fT(NL_fT >= p.cAllocfTsoil.maxL_fT)  = p.cAllocfTsoil.maxL_fT;
NL_fT(NL_fT <= p.cAllocfTsoil.minL_fT)  = p.cAllocfTsoil.minL_fT;
% NL_fT(NL_fT >= p.cAllocfTsoil.maxL_fT)  = p.cAllocfTsoil.maxL_fT(NL_fT >= p.cAllocfTsoil.maxL_fT);
% NL_fT(NL_fT <= p.cAllocfTsoil.minL_fT)  = p.cAllocfTsoil.minL_fT(NL_fT <= p.cAllocfTsoil.minL_fT);
fe.cAllocfTsoil.NL_fT                   = NL_fT;
end
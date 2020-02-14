function [f,fe,fx,s,d,p] = cAllocfwSoil_Friedlingstein1999(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % Compute partial computation for the moisture effect on
    % decomposition/mineralization
    %
    % Inputs:
    %   - d.cTaufwSoil.fwSoil:       values for effect of moisture on soil decomposition
    %   - p.cAllocfwSoil.maxL_fW:    maximum limitation for the moisture function (for pseudo Nutrient Limitation estimations) 
    %   - p.cAllocfwSoil.minL_fW:    minimum limitation for the moisture function (for pseudo Nutrient Limitation estimations)                
    %
    % Outputs:
    %   - d.cAllocfwSoil.NL_fW:      values for moisture stressor on C allocation  
    %
    % Modifies:
    %   - d.cAllocfwSoil.NL_fW
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

% computation for the moisture effect on decomposition/mineralization
NL_fW                                   = d.cTaufwSoil.fwSoil(:,tix);
NL_fW(NL_fW >= p.cAllocfwSoil.maxL_fW)  = p.cAllocfwSoil.maxL_fW;
NL_fW(NL_fW <= p.cAllocfwSoil.minL_fW)    = p.cAllocfwSoil.minL_fW;
% NL_fW(NL_fW >= p.cAllocfwSoil.maxL_fW)  = p.cAllocfwSoil.maxL_fW(NL_fW >=
% p.cAllocfwSoil.maxL_fW); %sujan
% NL_fW(NL_fW <= p.cAllocfwSoil.minL_fW)    = p.cAllocfwSoil.minL_fW(NL_fW <= p.cAllocfwSoil.minL_fW); %sujan
d.cAllocfwSoil.NL_fW(:,tix)             = NL_fW;

end
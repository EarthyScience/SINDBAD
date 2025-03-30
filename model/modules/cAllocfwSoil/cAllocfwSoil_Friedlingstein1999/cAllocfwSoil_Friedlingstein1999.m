function [f,fe,fx,s,d,p] = cAllocfwSoil_Friedlingstein1999(f,fe,fx,s,d,p,info,tix)
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % Compute partial computation for the moisture effect on
    % decomposition/mineralization
    %
    % Inputs:
    %   - d.cTaufwSoil.fwSoil:       values for effect of moisture on soil decomposition
    %   - p.cAllocfwSoil.maxL_fW:    maximum limitation for the moisture function (for pseudo Nutrient Limitation estimations)
    %   - p.cAllocfwSoil.mifW:    minimum limitation for the moisture function (for pseudo Nutrient Limitation estimations)
    %
    % Outputs:
    %   - d.cAllocfwSoil.fW:      values for moisture stressor on C allocation
    %
    % Modifies:
    %   - d.cAllocfwSoil.fW
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
    fW = d.cTaufwSoil.fwSoil(:, tix);
    fW(fW >= p.cAllocfwSoil.maxL_fW) = p.cAllocfwSoil.maxL_fW;
    fW(fW <= p.cAllocfwSoil.mifW) = p.cAllocfwSoil.mifW;
    % fW(fW >= p.cAllocfwSoil.maxL_fW)  = p.cAllocfwSoil.maxL_fW(fW >=
    % p.cAllocfwSoil.maxL_fW); %sujan
    % fW(fW <= p.cAllocfwSoil.mifW)    = p.cAllocfwSoil.mifW(fW <= p.cAllocfwSoil.mifW); %sujan
    d.cAllocfwSoil.fW(:, tix) = fW;

end

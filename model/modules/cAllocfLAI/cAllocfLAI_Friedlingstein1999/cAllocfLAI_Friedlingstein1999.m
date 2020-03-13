function [f,fe,fx,s,d,p] = cAllocfLAI_Friedlingstein1999(f,fe,fx,s,d,p,info,tix)
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % Compute the light limitation (LL) calculation
    %
    % Inputs:
    %   - s.cd.LAI: values for leaf area index
    %   - p.cAllocfLAI.minL: values for minimum resource availability (severely limited)
    %   - p.cAllocfLAI.maxL: values maximum resource availability (readily available)
    %   - p.cAllocfLAI.kext: values for light extinction coefficient
    %
    % Outputs:
    %   - d.cAllocfLAI.LL: values for light limitation
    %
    % Modifies:
    %   - d.cAllocfLAI.LL
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

    % light limitation (LL) calculation
    LL = exp(-p.cAllocfLAI.kext .* s.cd.LAI);
    LL(LL <= p.cAllocfLAI.minL) = p.cAllocfLAI.minL(LL <= p.cAllocfLAI.minL);
    LL(LL >= p.cAllocfLAI.maxL) = p.cAllocfLAI.maxL(LL >= p.cAllocfLAI.maxL);
    d.cAllocfLAI.LL(:, tix) = LL;
end

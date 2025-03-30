function [f,fe,fx,s,d,p] = cAllocfNut_Friedlingstein1999(f,fe,fx,s,d,p,info,tix)
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % pseudo-nutrient limitation (NL) calculation:
    % "There is no explicit estimate of soil mineral nitrogen in the version of
    % CASA used for these simulations. As a surrogate, we assume that spatial
    % variability in nitrogen mineralization and soil organic matter
    % decomposition are identical (Townsend et al. 1995). Nitrogen
    % availability, N, is calculated as the product of the temperature and
    % moisture abiotic factors used in CASA for the calculation of microbial
    % respiration (Potter et al. 1993)." in Friedlingstein et al., 1999.%
    %
    % Inputs:
    %   - fe.PET.PET:               values for potential evapotranspiration
    %   - fe.cAllocfTsoil.fT:    values for partial computation for the temperature effect on
    %                               decomposition/mineralization
    %   - d.cAllocfwSoil.fW:     values for partial computation for the moisture effect on
    %                               decomposition/mineralization
    %   - p.cAllocfNut.minL:        factor for minimum resource availability (severely limited)
    %   - p.cAllocfNut.maxL:        factor for maximum resource availability (readily available)
    %   - s.wd.pawAct:              values for maximum fraction of water that root can uptake from soil layers as constant
    %   - s.wd.p_wSoilBase_wAWC:    values for the plant water available
    %
    % Outputs:
    %   - fe.cAllocfNut.minWLNL: the pseudo-nutrient limitation (NL) calculation
    %
    % Modifies:
    %   - fe.cAllocfNut.minWLNL
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

    % estimate NL
    NL = p.cAllocfNut.minL .* ones(size(fe.PET.PET(:, tix)));
    ndx = fe.PET.PET(:, tix) > 0;
    NL(ndx) = fe.cAllocfTsoil.fT(ndx) .* d.cAllocfwSoil.fW(ndx);
    NL(NL <= p.cAllocfNut.minL) = p.cAllocfNut.minL; %(NL <= p.cAllocfNut.minL);
    NL(NL >= p.cAllocfNut.maxL) = p.cAllocfNut.maxL; %(NL >= p.cAllocfNut.maxL);
    %sujan NL(NL <= p.cAllocfNut.minL)    = p.cAllocfNut.minL(NL <= p.cAllocfNut.minL);
    %sujan NL(NL >= p.cAllocfNut.maxL)    = p.cAllocfNut.maxL(NL >= p.cAllocfNut.maxL);

    % sujan consider root fractions
    % water limitation calculation
    % WL                          = sum(s.w.wSoil .* s.wd.p_rootFrac_fracRoot2SoilD,2) ./ sum(s.wd.p_wSoilBase_wAWC .* s.wd.p_rootFrac_fracRoot2SoilD,2);
    WL = sum(s.wd.pawAct, 2) ./ sum(s.wd.p_wSoilBase_wAWC, 2);
    % WL                          = sum(s.w.wSoil,2) ./ sum(s.wd.p_wSoilBase_wAWC,2);
    WL(WL <= p.cAllocfNut.minL) = p.cAllocfNut.minL; %(WL <= p.cAllocfNut.minL);
    WL(WL >= p.cAllocfNut.maxL) = p.cAllocfNut.maxL; %(WL >= p.cAllocfNut.maxL);%% check if p.cAlloc.maxL and p.cAlloc.minL should used p.cAlloc.maxL_fW?
    %sujan WL(WL <= p.cAllocfNut.minL)    = p.cAllocfNut.minL(WL <= p.cAllocfNut.minL);
    %sujan WL(WL >= p.cAllocfNut.maxL) = p.cAllocfNut.maxL(WL >= p.cAllocfNut.maxL); %% check if p.cAlloc.maxL and p.cAlloc.minL should used p.cAlloc.maxL_fW?

    % minimum of WL and NL
    minWLNL = NL;
    minWLNL(WL < NL) = WL(WL < NL);

    fe.cAllocfNut.minWLNL(:, tix) = minWLNL;
end

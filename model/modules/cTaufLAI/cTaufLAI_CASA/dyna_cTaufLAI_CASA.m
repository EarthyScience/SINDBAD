function [f,fe,fx,s,d,p] = dyna_cTaufLAI_CASA(f,fe,fx,s,d,p,info,tix)
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % Compute the seasonal cycle of litter fall and root litter
    % "fall" based on LAI variations. Necessarily in precomputation mode
    %
    % Inputs:
    %   - f.LAI:                        leaf area index (m2/m2)
    %   - p.cTaufLAI.maxMinLAI:         parameter for the maximum value for the minimum LAI
    %                                   (m2/m2)
    %   - p.cTaufLAI.kRTLAI:            parameter for the constant fraction of root litter imputs
    %                                   to the soil ([])
    %   - info.timeScale.stepsPerYear:  number of years of simulations
    %
    % Outputs:
    %   - s.cd.p_cTaufLAI_kfLAI:  LAI stressor values on the the turnover rates based
    %                             on litter and root litter scalars
    %
    % Modifies:
    %   -
    %
    % References:
    %   - Potter, C. S., J. T. Randerson, C. B. Field, P. A. Matson, P. M.
    %     Vitousek, H. A. Mooney, and S. A. Klooster. 1993.  Terrestrial ecosystem
    %     production: A process model based on global satellite and surface data.
    %     Global Biogeochemical Cycles. 7: 811-841.
    %
    % Created by:
    %   - ncarvalhais
    %
    % Versions:
    %   - 1.0 on 12.01.2020 (sbesnard)
    %   - 1.1 on 05.11.2020 (skoirala): speedup 
    %
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    % PARAMETERS
    maxMinLAI = p.cTaufLAI.maxMinLAI;
    kRTLAI = p.cTaufLAI.kRTLAI;

    %--> Get the number of time steps per year
    TSPY = info.tem.model.time.nStepsYear;
    % make sure TSPY is integer
    if rem(TSPY, 1) ~= 0, TSPY = floor(TSPY); end

    % BUILD AN ANNUAL LAI MATRIX
    %--> get the LAI of previous time step in LAI13
    LAI13 = s.cd.p_cTaufLAI_LAI13;
    LAI13 = circshift(LAI13,1,2);
%     LAI13(:, 2:TSPY + 1) = LAI13(:, 1:TSPY); % very slow (sujan)
    LAI13(:, 1) = s.cd.LAI;
    
    
    LAI13_next = LAI13(:, 2:TSPY + 1);
    
%     LAI13_prev = LAI13(:, 1:TSPY);
    %--> update s
    s.cd.p_cTaufLAI_LAI13 = LAI13;

    %--> Calculate sum of deltaLAI over the year
    dLAI    = diff(LAI13,1,2);
    dLAI = max(dLAI, 0);
    dLAIsum = sum(dLAI, 2);

    %--> Calculate average and minimum LAI
    LAIsum = sum(LAI13_next, 2);
    LAIave = LAIsum ./ size(LAI13_next, 2);
    LAImin = min(LAI13_next, [], 2);
    LAImin(LAImin > maxMinLAI) = maxMinLAI(LAImin > maxMinLAI);

    %--> Calculate constant fraction of LAI (LTCON)
    LTCON = info.tem.helpers.arrays.zerospix;
    ndx = (LAIave > 0);
    LTCON(ndx) = LAImin(ndx) ./ LAIave(ndx);

    %--> Calculate deltaLAI
    dLAI = dLAI(:,1);

    %--> Calculate variable fraction of LAI (LTCON)
    LTVAR = info.tem.helpers.arrays.zerospix;
    LTVAR(dLAI <= 0 | dLAIsum <= 0) = 0;
    ndx = (dLAI > 0 | dLAIsum > 0);
    LTVAR(ndx) = (dLAI(ndx) ./ dLAIsum(ndx));

    %--> Calculate the scalar for litterfall
    LTLAI = LTCON ./ TSPY + (1 - LTCON) .* LTVAR;

    %--> Calculate the scalar for root litterfall
%     RTLAI = zeros(size(LTLAI));
    RTLAI = info.tem.helpers.arrays.zerospix;
    
    ndx = (LAIsum > 0);
    LAI131st = LAI13(:, 1);
    RTLAI(ndx) = (1 - kRTLAI) .* (LTLAI(ndx) + LAI131st(ndx) ./ ...
        LAIsum(ndx)) ./ 2 + kRTLAI ./ TSPY;

    %--> Feed the output fluxes to cCycle components
    zix_veg = s.cd.p_cTaufLAI_cVegLeafZix;
    s.cd.p_cTaufLAI_kfLAI(:, zix_veg) = s.cd.p_cCycleBase_annk(:, zix_veg) .* LTLAI ./ s.cd.p_cCycleBase_k(:, zix_veg); % leaf litter scalar

    zix_root = s.cd.p_cTaufLAI_cVegRootZix;
    s.cd.p_cTaufLAI_kfLAI(:, zix_root) = s.cd.p_cCycleBase_annk(:, zix_root) .* RTLAI ./ s.cd.p_cCycleBase_k(:, zix_root); % root litter scalar
end

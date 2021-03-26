function [f,fe,fx,s,d,p] = dyna_cCycle_CASA(f,fe,fx,s,d,p,info,tix)
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % Perform carbon cycle between pools
    %
    % Inputs:
    %   - fx.gpp:                   values for gross primary productivity
    %   - s.cd.cAlloc:              carbon allocation matrix
    %   - s.cd.p_cFlowAct_taker:    taker pool array
    %   - s.cd.p_cFlowAct_giver:    giver pool array
    %   - s.cd.p_cFlowAct_E:        effect of soil and vegetation on transfer efficiency between pools
    %
    % Outputs:
    %   - s.c.cEco:    values for the different carbon pools
    %   - fx.cRH:      values for heterotrophic respiration
    %   - fx.cRA:      values for autotrophic respiration
    %   - fx.cRECO:    values for ecosystem respiration
    %   - fx.cNPP:     values for net primary productivity
    %
    % Modifies:
    %   -
    %
    % References:
    %   - Carvalhais, N., Reichstein, M., Seixas, J., Collatz, G. J., Pereira, J. S., Berbigier, P.,
    %       ... & Rambal, S. (2008). Implications of the carbon cycle steady state assumption for
    %       biogeochemical modeling performance and inverse parameter retrieval. Global Biogeochemical Cycles, 22(2).
    %   - Potter, C. S., Randerson, J. T., Field, C. B., Matson, P. A., Vitousek, P. M., Mooney, H. A.,
    %       & Klooster, S. A. (1993). Terrestrial ecosystem production: a process model based on global
    %       satellite and surface data. Global Biogeochemical Cycles, 7(4), 811-841.
    %   - Potter, C., Klooster, S., Myneni, R., Genovese, V., Tan, P. N., & Kumar, V. (2003).
    %       Continental-scale comparisons of terrestrial carbon sinks estimated from satellite data and ecosystem
    %       modeling 1982–1998. Global and Planetary Change, 39(3-4), 201-213.
    %
    % Created by:
    %   - ncarvalhais
    %
    % Versions:
    %   - 1.0 on 28.02.2020 (sbesnard)
    %
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    %% these all need to be zeros... maybe is taken care automatically...
    s.cd.cEcoInflux = info.tem.helpers.arrays.zerospixzix.c.cEco;
    s.cd.cEcoFlow = info.tem.helpers.arrays.zerospixzix.c.cEco;
    s.cd.cEcoEfflux(:, ~info.tem.model.variables.states.c.flags.cVeg) = 0;

    %% compute losses
    s.cd.cEcoOut = min(s.c.cEco, s.c.cEco .* s.cd.p_cTauAct_k);

    %% gains to vegetation
    zix = info.tem.model.variables.states.c.flags.cVeg;
    s.cd.cNPP = fx.gpp(:, tix) .* s.cd.cAlloc(:, zix) - s.cd.cEcoEfflux(:, zix);
    s.cd.cEcoInflux(:, zix) = s.cd.cNPP;

    %% flows and losses
    % @nc, if flux order does not matter, remove...
    for jix = 1:numel(p.cCycleBase.fluxOrder)
        taker = s.cd.p_cFlowAct_taker(p.cCycleBase.fluxOrder(jix));
        giver = s.cd.p_cFlowAct_giver(p.cCycleBase.fluxOrder(jix));
        out = s.cd.cEcoOut(:, giver) .* s.cd.p_cFlowAct_F(:, taker, giver);
        s.cd.cEcoFlow(:, taker) = s.cd.cEcoFlow(:, taker) + out .* s.cd.p_cFlowAct_E(:, taker, giver);
        s.cd.cEcoEfflux(:, giver) = s.cd.cEcoEfflux(:, giver) + out .* (1 - s.cd.p_cFlowAct_E(:, taker, giver));
    end

    %% balance
    s.c.cEco = s.c.cEco + s.cd.cEcoFlow + s.cd.cEcoInflux - s.cd.cEcoOut;

    %% compute RA and RH
    fx.cRH(:, tix) = sum(s.cd.cEcoEfflux(:, ~info.tem.model.variables.states.c.flags.cVeg), 2); %sujan added 2 to sum along all pools
    fx.cRA(:, tix) = sum(s.cd.cEcoEfflux(:, info.tem.model.variables.states.c.flags.cVeg), 2); %sujan added 2 to sum along  all pools
    fx.cRECO(:, tix) = fx.cRH(:, tix) + fx.cRA(:, tix);
    fx.cNPP(:, tix)  = sum(s.cd.cNPP, 2);
    fx.NEE(:, tix)   = fx.cRECO(:, tix) - fx.gpp(:, tix);
end

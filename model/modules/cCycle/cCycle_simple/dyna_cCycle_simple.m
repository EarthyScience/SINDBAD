function [f,fe,fx,s,d,p] = dyna_cCycle_simple(f,fe,fx,s,d,p,info,tix)
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
    %   - Potter, C. S., J. T. Randerson, C. B. Field, P. A. Matson, P. M.
    %     Vitousek, H. A. Mooney, and S. A. Klooster. 1993.  Terrestrial ecosystem
    %     production: A process model based on global satellite and surface data.
    %     Global Biogeochemical Cycles. 7: 811-841.
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
    %% compute losses
    s.cd.cEcoOut = min(s.c.cEco, s.c.cEco .* s.cd.p_cTauAct_k);
    %% gains to vegetation
    zix = info.tem.model.variables.states.c.flags.cVeg;
    s.cd.cNPP = fx.gpp(:, tix) .* s.cd.cAlloc(:, zix) - s.cd.cEcoEfflux(:, zix);
    s.cd.cEcoInflux(:, zix) = s.cd.cNPP;
    % flows and losses
    % @nc, if flux order does not matter, remove...
    % sujanq: this was deleted by simon in the version of 2020-11. Need to
    % find out why. Led to having zeros in most of the carbon pools of the
    % explicit simple
    % old before cleanup... was removed during biomascat when cFlowAct was changed to gsi. But original cFlowAct CASA was writing p.cCycleBase.fluxOrder. So, in biomascat, the fields do not exist and this block of code will not work.
    for jix = 1:numel(p.cCycleBase.fluxOrder)
        taker                       = s.cd.p_cFlowAct_taker(p.cCycleBase.fluxOrder(jix));
        giver                       = s.cd.p_cFlowAct_giver(p.cCycleBase.fluxOrder(jix));
        s.cd.cEcoFlow(:,taker)      = s.cd.cEcoFlow(:,taker)   + s.cd.cEcoOut(:,giver) .* s.cd.p_cFlowAct_A(:,taker,giver);
    end
%     for jix = 1:numel(s.cd.p_cFlowAct_taker)
%         taker                       = s.cd.p_cFlowAct_taker(jix);
%         giver                       = s.cd.p_cFlowAct_giver(jix);
%         c_flow                      = s.cd.p_cFlowAct_A(:,taker,giver);
%         take_flow                   = s.cd.cEcoFlow(:,taker);
%         give_flow                   = s.cd.cEcoOut(:,giver);
%         s.cd.cEcoFlow(:,taker)      = take_flow  + give_flow .* c_flow;
%     end

    %% balance
    prevcEco = s.c.cEco;
    s.c.cEco = s.c.cEco + s.cd.cEcoFlow + s.cd.cEcoInflux - s.cd.cEcoOut;
    %% compute RA and RH
    s.cd.del_cEco = s.c.cEco - s.prev.s_c_cEco;
    fx.cNPP(:, tix) = sum(s.cd.cNPP, 2);
    backNEP = sum(s.c.cEco, 2) - sum(prevcEco, 2);
    fx.cRA(:, tix) = fx.gpp(:, tix) - fx.cNPP(:, tix);
    fx.cRECO(:, tix) = fx.gpp(:, tix) - backNEP;
    fx.cRH(:, tix) = fx.cRECO(:, tix) - fx.cRA(:, tix);
    fx.NEE(:, tix) = fx.cRECO(:, tix) - fx.gpp(:, tix);
end

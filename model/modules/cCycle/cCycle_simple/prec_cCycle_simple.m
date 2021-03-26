function [f,fe,fx,s,d,p] = prec_cCycle_simple(f,fe,fx,s,d,p,info)
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % Calculate decay rates for the ecosystem C pools at appropriate
    % time steps
    %
    % Inputs:
    %   - info.tem.model.time.nStepsYear:   number of time steps per year
    %   - s.cd.p_cCycleBase_annk:               carbon allocation matrix
    %
    % Outputs:
    %   - s.cd.p_cCycleBase_k:  decay rates for the carbon pool at each time step
    %   - s.cd.cEcoEfflux:
    %
    % Modifies:
    %   -
    %
    % References:
    %   -
    %
    % Created by:
    %   - ncarvalhais
    %
    % Versions:
    %   - 1.0 on 28.02.2020 (sbesnard)
    %
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    TSPY = info.tem.model.time.nStepsYear; % NUMBER OF TIME STEPS PER YEAR
    s.cd.p_cCycleBase_k = 1 - (exp(-s.cd.p_cCycleBase_annk).^(1 ./ TSPY));
    s.cd.cEcoEfflux = info.tem.helpers.arrays.zerospixzix.c.cEco; %sujan moved from get states
    s.cd.cEcoOut = info.tem.helpers.arrays.onespixzix.c.cEco;
    s.cd.cEcoFlow = info.tem.helpers.arrays.onespixzix.c.cEco;
end

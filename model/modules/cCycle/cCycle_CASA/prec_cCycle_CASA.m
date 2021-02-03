function [f,fe,fx,s,d,p] = prec_cCycle_CASA(f,fe,fx,s,d,p,info)
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

    % NUMBER OF TIME STEPS PER YEAR
    TSPY = info.tem.model.time.nStepsYear;
    % s.prev.cTaufwSoil_fwSoil=info.tem.helpers.arrays.onespixzix.c.cEco; %sujan
    s.cd.p_cCycleBase_k = 1 - (exp(-s.cd.p_cCycleBase_annk).^(1 ./ TSPY));
    s.cd.cEcoEfflux = info.tem.helpers.arrays.zerospixzix.c.cEco; %sujan moved from get states

end

function [f,fe,fx,s,d,p] = prec_cCycleBase_CASA(f,fe,fx,s,d,p,info)
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % Compute carbon to nitrogen ratio and  annual turnover rates
    %
    % Inputs:
    %   - p.cCycleBase.C2Nveg:            carbon to nitrogen ratio in vegetation pools
    %   - p.cCycleBase.annk:              turnover rate of ecosystem carbon pools
    %
    % Outputs:
    %   - s.cd.p_cCycleBase_C2Nveg:    carbon to nitrogen ratio in vegetation pools
    %   - s.cd.p_cCycleBase_annk:      turnover rate of ecosystem carbon pools
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
    %
    % Created by:
    %   - ncarvalhais
    %
    % Versions:
    %   - 1.0 on 28.02.2020 (sbesnard)
    %
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    % carbon to nitrogen ratio (gC.gN-1)
    s.cd.p_cCycleBase_C2Nveg = zeros(info.tem.helpers.sizes.nPix, numel(info.tem.model.variables.states.c.zix.cVeg)); %sujan

    for zix = info.tem.model.variables.states.c.zix.cVeg
        s.cd.p_cCycleBase_C2Nveg(:, zix) = p.cCycleBase.C2Nveg(zix);
    end

    % annual turnover rates
    s.cd.p_cCycleBase_annk = reshape(repelem(p.cCycleBase.annk, info.tem.helpers.sizes.nPix), info.tem.helpers.sizes.nPix, info.tem.model.variables.states.c.nZix.cEco); %sujan

end %function

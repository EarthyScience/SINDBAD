function [f,fe,fx,s,d,p] = prec_cCycleBase_simple(f,fe,fx,s,d,p,info)
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % Compute carbon to nitrogen ratio and  annual turnover rates
    %
    % Inputs:
    %   - p.cCycleBase.C2Nveg:            carbon to nitrogen ratio in vegetation pools
    %   - p.cCycleBase.annk:              turnover rate of ecosystem carbon pools
    %
    %
    % Outputs:
    %   - s.cd.p_cCycleBase_C2Nveg:    carbon to nitrogen ratio in vegetation pools
    %   - s.cd.p_cCycleBase_annk:      turnover rate of ecosystem carbon pools
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

    %carbon to nitrogen ratio (gC.gN-1)
    s.cd.p_cCycleBase_C2Nveg = zeros(info.tem.helpers.sizes.nPix, numel(info.tem.model.variables.states.c.zix.cVeg)); %sujan

    for zix = info.tem.model.variables.states.c.zix.cVeg
        s.cd.p_cCycleBase_C2Nveg(:, zix) = p.cCycleBase.C2Nveg(zix);
    end

    % annual turnover rates
    s.cd.p_cCycleBase_annk = reshape(repelem(p.cCycleBase.annk, info.tem.helpers.sizes.nPix), info.tem.helpers.sizes.nPix, info.tem.model.variables.states.c.nZix.cEco); %sujan

end %function

function [f, fe, fx, s, d, p] = dyna_cAllocfTreeFrac_Friedlingstein1999(f, fe, fx, s, d, p, info, tix)
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % adjust the allocation coefficients according to the fraction of
    % trees to herbaceous and fine to coarse root partitioning
    %
    % Inputs:
    %   - p.pVeg.TreeFrac:            values for tree cover
    %   - p.cAllocfTreeFrac.Rf2Rc:    values for fine root to coarse root fraction
    %   - s.cd.cAlloc:                 the fraction of NPP that is allocated to the different plant organs
    %
    % Outputs:
    %   - s.cd.cAlloc: adjusted fraction of NPP that is allocated to the different plant organs
    %
    % Modifies:
    %   - s.cd.cAlloc
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

    % TreeFrac and fine to coarse root ratio
    tc = p.pVeg.TreeFrac;
    rf2rc = p.cAllocfTreeFrac.Rf2Rc;

    % the allocation fractions according to the partitioning to root/wood/leaf
    % - represents plant level allocation
    r0 = sum(s.cd.cAlloc(:, info.tem.model.variables.states.c.zix.cVegRoot), 2); % this is to below ground root fine+coarse
    s0 = sum(s.cd.cAlloc(:, info.tem.model.variables.states.c.zix.cVegWood), 2);
    l0 = sum(s.cd.cAlloc(:, info.tem.model.variables.states.c.zix.cVegLeaf), 2);

    % adjust for spatial consideration of TreeFrac and plant level
    % partitioning between fine and coarse roots
    cF.cVegRootF = tc .* rf2rc + (r0 + s0 .* (r0 ./ (r0 + l0))) .* (1 - tc);
    cF.cVegRootC = tc .* (1 - rf2rc);
    cF.cVegRoot = cF.cVegRootF + cF.cVegRootC;
    cF.cVegWood = tc;
    cF.cVegLeaf = tc + (l0 + s0 .* (l0 ./ (r0 + l0))) .* (1 - tc);
    % adjust the allocation parameters

    for cpN = 1:numel(s.cd.p_cAllocfTreeFrac_cVegName)
        cpName = s.cd.p_cAllocfTreeFrac_cVegName(cpN);
        zix = s.cd.p_cAllocfTreeFrac_cVegZix{cpN};
        s.cd.cAlloc(:, zix) = cF.(cpName) .* s.cd.cAlloc(:, zix);
    end


    % for cp = s.cd.p_cAllocfTreeFrac_cVegName
    %     zix = info.tem.model.variables.states.c.zix.(cp);
    %     s.cd.cAlloc(:, zix) = cF.(cp) .* s.cd.cAlloc(:, zix);
    % end


    % originally before 2020-11-05
    % check if there are fine and coarse root pools...
    % if isfield(info.tem.model.variables.states.c.components, 'cVegWoodC') && ...
    %     isfield(info.tem.model.variables.states.c.components, 'cVegWoodF')
    %     cpNames = {'cVegRootF', 'cVegRootC', 'cVegWood', 'cVegLeaf'};
    % else
    %     cpNames = {'cVegRoot', 'cVegWood', 'cVegLeaf'};
    % end

    % % adjust the allocation parameters
    % for cp = cpNames
    %     zix = info.tem.model.variables.states.c.zix.(cp{:});
    %     s.cd.cAlloc(:, zix) = cF.(cp{:}) .* s.cd.cAlloc(:, zix);
    % end
end

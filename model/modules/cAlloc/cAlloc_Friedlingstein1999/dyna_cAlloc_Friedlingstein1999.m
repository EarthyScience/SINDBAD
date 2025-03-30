function [f,fe,fx,s,d,p] = dyna_cAlloc_Friedlingstein1999(f,fe,fx,s,d,p,info,tix)
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % compute the fraction of NPP that is allocated to the
    % different plant organs following the scheme of Friedlingstein et al 1999.
    % Check cAlloc_Friedlingstein1999 for details.
    %
    % Inputs:
    %   - fe.cAllocfNut.minWLNL: values for the pseudo-nutrient limitation
    %   - d.cAllocfLAI.LL:       values for light limitation
    %   - p.cAlloc.ro:           carbon allocation to root for non-limiting conditions
    %   - p.cAlloc.RelY:         relative importance of investments to acquire Y-type  resources (see Friedlingstein et al 1999 section Allocation and resources estimate for ambient conditions
    %   - p.cAlloc.so:           carbon allocation to stem for non-limiting conditions
    %
    % Outputs:
    %   - s.cd.cAlloc: the fraction of NPP that is allocated to the different plant organs
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

    % allocation to root, wood and leaf
    cf2.cVegRoot = p.cAlloc.ro .* (p.cAlloc.RelY + 1) .* d.cAllocfLAI.LL(:, tix) ./ (d.cAllocfLAI.LL(:, tix) + p.cAlloc.RelY .* fe.cAllocfNut.minWLNL(:, tix));
    cf2.cVegWood = p.cAlloc.so .* (p.cAlloc.RelY + 1) .* fe.cAllocfNut.minWLNL(:, tix) ./ (p.cAlloc.RelY .* d.cAllocfLAI.LL(:, tix) + fe.cAllocfNut.minWLNL(:, tix));
    cf2.cVegLeaf = 1 - cf2.cVegRoot - cf2.cVegWood;

    % distribute the allocation according to pools...
    cpNames = {'cVegRoot', 'cVegWood', 'cVegLeaf'};

    for cpn = 1:numel(cpNames)
        zixVec = info.tem.model.variables.states.c.zix.(cpNames{cpn});
        N = numel(zixVec);

        for zix = zixVec
            s.cd.cAlloc(:, zix) = cf2.(cpNames{cpn}) ./ N;
        end

    end

end

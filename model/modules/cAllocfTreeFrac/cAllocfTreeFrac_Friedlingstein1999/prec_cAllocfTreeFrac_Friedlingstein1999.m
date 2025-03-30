function [f,fe,fx,s,d,p] = prec_cAllocfTreeFrac_Friedlingstein1999(f,fe,fx,s,d,p,info,tix)
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
    % check if there are fine and coarse root pools...
    if isfield(info.tem.model.variables.states.c.components, 'cVegWoodC') && ...
            isfield(info.tem.model.variables.states.c.components, 'cVegWoodF')
        cpNames = ["cVegRootF", "cVegRootC", "cVegWood", "cVegLeaf"];
        zixVecs = {
            info.tem.model.variables.states.c.zix.cVegRootF;
            info.tem.model.variables.states.c.zix.cVegRootC;
            info.tem.model.variables.states.c.zix.cVegWood;
            info.tem.model.variables.states.c.zix.cVegLeaf;
        }    
    else
        cpNames = ["cVegRoot", "cVegWood", "cVegLeaf"];
        zixVecs = {
            info.tem.model.variables.states.c.zix.cVegRoot;
            info.tem.model.variables.states.c.zix.cVegWood;
            info.tem.model.variables.states.c.zix.cVegLeaf;
        }    
    end

    s.cd.p_cAllocfTreeFrac_cVegZix = zixVecs;
    s.cd.p_cAllocfTreeFrac_cVegName = cpNames;

    % for cp = 1:numel(cpNames)
    %     zix = info.tem.model.variables.states.c.zix.(cpNames(cp));
    %     s.cd.p_cAllocfTreeFrac_cVegZix(cp)=zix;
    % end

end

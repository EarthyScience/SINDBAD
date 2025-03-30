function [f,fe,fx,s,d,p] = prec_cAlloc_gsi(f,fe,fx,s,d,p,info,tix)
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % set the allocation to zeros
    s.cd.cAlloc = info.tem.helpers.arrays.zerospixzix.c.cEco; %sbesnard
    s.cd.p_cAlloc_cpNames = ["cVegRoot", "cVegWood", "cVegLeaf"];

    s.cd.p_cAlloc_zixVecs = {
        info.tem.model.variables.states.c.zix.cVegRoot;
        info.tem.model.variables.states.c.zix.cVegWood;
        info.tem.model.variables.states.c.zix.cVegLeaf;
    }
end

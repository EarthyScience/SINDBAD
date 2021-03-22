function [f,fe,fx,s,d,p] = prec_raAct_Thornley2000B(f,fe,fx,s,d,p,info)
    s.cd.p_raAct_km = repmat(info.tem.helpers.arrays.onespix ,1,numel(info.tem.model.variables.states.c.zix.cVeg));
    s.cd.p_raAct_km4su = s.cd.p_raAct_km;
    s.cd.RA_G = s.cd.p_raAct_km;
    s.cd.RA_M = s.cd.p_raAct_km;
end

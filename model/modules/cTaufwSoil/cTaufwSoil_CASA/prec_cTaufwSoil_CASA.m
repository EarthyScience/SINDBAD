function [f,fe,fx,s,d,p] = prec_cTaufwSoil_CASA(f,fe,fx,s,d,p,info)
    s.cd.p_cTaufwSoil_fwSoil = info.tem.helpers.arrays.onespixzix.c.cEco; 
end

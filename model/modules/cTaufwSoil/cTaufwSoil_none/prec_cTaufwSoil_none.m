function [f,fe,fx,s,d,p] = prec_cTaufwSoil_none(f,fe,fx,s,d,p,info)
    % set the moisture stress for all carbon pools to ones
    s.cd.p_cTaufwSoil_fwSoil = info.tem.helpers.arrays.onespixzix.c.cEco;
end

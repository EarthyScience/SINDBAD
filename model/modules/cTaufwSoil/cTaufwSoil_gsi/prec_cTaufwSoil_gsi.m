function [f,fe,fx,s,d,p] = prec_cTaufwSoil_gsi(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculate the moisture stress for cTau based on temperature stressor function of CASA and Potter
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
s.cd.p_cTaufwSoil_fwSoil = info.tem.helpers.arrays.onespixzix.c.cEco;

end
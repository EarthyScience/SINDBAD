function [f,fe,fx,s,d,p] = prec_cTaufpSoil_none(f,fe,fx,s,d,p,info)
% no effect = 1;
s.cd.p_cTaufpSoil_kfSoil 		= info.tem.helpers.arrays.onespixzix.c.cEco;
% (ineficient, should be pix zix_mic)
end %function

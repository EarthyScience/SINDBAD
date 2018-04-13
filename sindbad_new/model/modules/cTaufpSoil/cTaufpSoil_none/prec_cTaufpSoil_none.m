function [fe,fx,d,p,f] = prec_cTaufpSoil_none(f,fe,fx,s,d,p,info)
% no effect = 1;
s.cd.cTaufpSoil = ones(info.tem.helpers.npix,info.tem.helpers.nzix.c);
end %function

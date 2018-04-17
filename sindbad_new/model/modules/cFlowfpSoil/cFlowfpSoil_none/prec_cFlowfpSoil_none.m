function [fe,fx,d,p,f] = prec_cFlowfpSoil_none(f,fe,fx,s,d,p,info)
% no effect = 1;
s.cd.cFlowfpSoil = ones(info.tem.helpers.npix,info.tem.helpers.nzix.c);
end %function

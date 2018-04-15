function [fe,fx,d,p,f] = prec_cFlowfpVeg_none(f,fe,fx,s,d,p,info)
% no effect = 1;
s.cd.cFlowfpVeg = ones(info.tem.helpers.npix,info.tem.helpers.nzix.c);
end %function

function [f,fe,fx,s,d,p] = prec_gppDem_mult(f,fe,fx,s,d,p,info)
% see dyna_gppDem_mult
%--> create an empty matrix with 4 layers for 4 scalars.
s.cd.scall               =   repmat(info.tem.helpers.arrays.onespix,1,4);
end
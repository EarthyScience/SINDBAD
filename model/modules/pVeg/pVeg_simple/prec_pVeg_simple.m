function [f,fe,fx,s,d,p] = prec_pVeg_simple(f,fe,fx,s,d,p,info)
p.pVeg.PFT = p.pVeg.PFT .* info.tem.helpers.arrays.onespix;
end
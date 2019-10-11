function [f,fe,fx,s,d,p] = prec_pVeg_vegFrac(f,fe,fx,s,d,p,info)
p.pVeg.vegFr = p.pVeg.vegFr .* info.tem.helpers.arrays.onespix;
end

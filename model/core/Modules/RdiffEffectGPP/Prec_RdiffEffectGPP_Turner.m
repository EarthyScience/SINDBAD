function [fe,fx,d,p] = Prec_RdiffEffectGPP_Turner(f,fe,fx,s,d,p,info)

prue2                   = p.RdiffEffectGPP.rue2 * ones(1,info.forcing.size(2));
prue1                   = p.RdiffEffectGPP.rue1 * ones(1,info.forcing.size(2));
d.RdiffEffectGPP.rueGPP	= (prue2 - prue1) .* (1 - f.Rg ./ f.RgPot ) + prue1;    

end
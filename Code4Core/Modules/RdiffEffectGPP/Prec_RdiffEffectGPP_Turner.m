function [fe,fx,d,p]=Prec_RdiffEffectGPP_Turner(f,fe,fx,s,d,p,info);


 d.RdiffEffectGPP.rueGPP = ( p.RdiffEffectGPP.rue2 - p.RdiffEffectGPP.rue1 ).*(1 - f.Rg ./ f.RgPot ) + p.RdiffEffectGPP.rue1;    



end
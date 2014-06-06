function [fe,fx,d]=Prec_RdiffEffectGPP_Turner(f,fe,fx,s,d,p,info);


 d.RdiffEffectGPP.rueGPP=(p.RdiffEffectGPP.rue2-p.RdiffEffectGPP.rue1).*(1-fi.Rg./fi.RgPot)+p.RdiffEffectGPP.rue1;    



end
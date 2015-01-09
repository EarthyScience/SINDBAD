function [fe,fx,d,p]=Prec_RdiffEffectGPP_none(f,fe,fx,s,d,p,info);

%just put here a single light use efficiency
 d.RdiffEffectGPP.rueGPP = zeros(info.forcing.size) + p.RdiffEffectGPP.rue;



end
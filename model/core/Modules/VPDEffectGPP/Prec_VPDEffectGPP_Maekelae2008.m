function [fe,fx,d,p] = Prec_VPDEffectGPP_Maekelae2008(f,fe,fx,s,d,p,info)

%p.VPDEffectGPP.k [-0.06 -0.7]; median ~-0.4

pk                      = p.VPDEffectGPP.k * ones(1,info.forcing.size(2));
d.VPDEffectGPP.VPDScGPP = exp(pk .* f.VPDDay);

end
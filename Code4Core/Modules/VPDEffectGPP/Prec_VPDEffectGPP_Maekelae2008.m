function [fe,fx,d,p]=Prec_VPDEffectGPP_Maekelae2008(f,fe,fx,s,d,p,info);

%p.VPDEffectGPP.k [-0.06 -0.7]; median ~-0.4

d.VPDEffectGPP.VPDScGPP = exp( p.VPDEffectGPP.k .* f.VPDDay );

end
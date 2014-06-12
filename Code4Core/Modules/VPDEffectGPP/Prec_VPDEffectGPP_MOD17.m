function [fe,fx,d,p]=Prec_VPDEffectGPP_MOD17(f,fe,fx,s,d,p,info);

td = p.VPDEffectGPP.VPDmax - p.VPDEffectGPP.VPDmin;
vsc=- f.VPDDay ./ td + p.VPDEffectGPP.VPDmax ./ td;

vsc(vsc<0)=0;
vsc(vsc>1)=1;

d.VPDEffectGPP.VPDScGPP = vsc;

end
function [fe,fx,d,p]=Prec_VPDEffectGPP_MOD17(f,fe,fx,s,d,p,info);

td = repmat( p.VPDEffectGPP.VPDmax - p.VPDEffectGPP.VPDmin ,1,info.Forcing.Size(2));
vsc=- f.VPDDay ./ td + repmat( p.VPDEffectGPP.VPDmax ,1,info.Forcing.Size(2)) ./ td;

vsc(vsc<0)=0;
vsc(vsc>1)=1;

d.VPDEffectGPP.VPDScGPP = vsc;

end
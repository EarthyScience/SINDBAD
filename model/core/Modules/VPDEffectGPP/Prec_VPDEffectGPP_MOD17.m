function [fe,fx,d,p] = Prec_VPDEffectGPP_MOD17(f,fe,fx,s,d,p,info)

tmp     = ones(1,info.forcing.size(2));
td      = (p.VPDEffectGPP.VPDmax - p.VPDEffectGPP.VPDmin)   * tmp;
pVPDmax = p.VPDEffectGPP.VPDmax                             * tmp;

vsc     = - f.VPDDay ./ td + pVPDmax ./ td;

vsc(vsc<0)  = 0;
vsc(vsc>1)  = 1;

d.VPDEffectGPP.VPDScGPP = vsc;

end
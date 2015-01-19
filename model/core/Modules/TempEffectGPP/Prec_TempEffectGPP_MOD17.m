function [fe,fx,d,p] = Prec_TempEffectGPP_MOD17(f,fe,fx,s,d,p,info)


tmp     = ones(1,info.forcing.size(2));
td      = (p.TempEffectGPP.Tmax - p.TempEffectGPP.Tmin) * tmp;
tmax    = p.TempEffectGPP.Tmax * tmp;

tsc                         = f.TairDay ./ td + 1 - tmax ./ td;
tsc(tsc<0)                  = 0;
tsc(tsc>1)                  = 1;
d.TempEffectGPP.TempScGPP   = tsc;

end
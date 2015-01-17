function [fe,fx,d,p] = Prec_TempEffectGPP_WP(f,fe,fx,s,d,p,info)

% hmmmmmm shouldn't this be kelvin??

pTmax   = p.TempEffectGPP.Tmax * ones(1,info.forcing.size(2));
tsc     = f.TairDay ./ pTmax;

tsc(tsc<0)  = 0;
tsc(tsc>1)  = 1;

d.TempEffectGPP.TempScGPP = tsc;

end
function [fe,fx,d,p]=Prec_TempEffectGPP_MOD17(f,fe,fx,s,d,p,info);


td = p.TempEffectGPP.Tmax - p.TempEffectGPP.Tmin;
tsc = f.TairDay ./ td +1 - p.TempEffectGPP.Tmax ./ td;

tsc(tsc<0)=0;
tsc(tsc>1)=1;

d.TempEffectGPP.TempScGPP = tsc;

end
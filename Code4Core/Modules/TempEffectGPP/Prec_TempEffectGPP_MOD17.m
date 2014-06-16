function [fe,fx,d,p]=Prec_TempEffectGPP_MOD17(f,fe,fx,s,d,p,info);


td = repmat( p.TempEffectGPP.Tmax - p.TempEffectGPP.Tmin ,1,info.Forcing.Size(2));
tsc = f.TairDay ./ td +1 - repmat( p.TempEffectGPP.Tmax ,1,info.Forcing.Size(2)) ./ td;

tsc(tsc<0)=0;
tsc(tsc>1)=1;

d.TempEffectGPP.TempScGPP = tsc;

end
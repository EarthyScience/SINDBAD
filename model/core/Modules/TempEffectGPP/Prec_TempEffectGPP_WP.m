function [fe,fx,d,p]=Prec_TempEffectGPP_WP(f,fe,fx,s,d,p,info);

tsc = f.TairDay ./ repmat( p.TempEffectGPP.TmaxWP ,1,info.forcing.size(2));
tsc(tsc<0)=0;
tsc(tsc>1)=1;

d.TempEffectGPP.TempScGPP = tsc;

end
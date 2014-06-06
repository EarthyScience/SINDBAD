function [fe,fx,d]=Prec_TempEffectGPP_WP(f,fe,fx,s,d,p,info);

tsc=f.TairDay./p.TempEffectGPP.TmaxWP;
tsc(tsc<0)=0;
tsc(tsc>1)=1;

d.TempEffectGPP.TempScGPP=tsc;

end
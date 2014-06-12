function [fe,fx,d,p]=Prec_TempEffectGPP_TEM(f,fe,fx,s,d,p,info);


  term1 = f.TairDay - p.TempEffectGPP.TminTEM;
  term2 = f.TairDay - p.TempEffectGPP.TmaxTEM;
  
  d.TempEffectGPP.TempScGPP = max(term1.*term2 ./ ((term1.*term2) - ( f.TairDay - p.TempEffectGPP.ToptTEM ).^2),0);

end
function [fe,fx,d,p]=Prec_TempEffectGPP_TEM(f,fe,fx,s,d,p,info);


  term1 = f.TairDay - repmat( p.TempEffectGPP.TminTEM ,1,info.Forcing.Size(2));
  term2 = f.TairDay - repmat( p.TempEffectGPP.TmaxTEM ,1,info.Forcing.Size(2));
  
  d.TempEffectGPP.TempScGPP = max(term1.*term2 ./ ((term1.*term2) - ( f.TairDay - repmat( p.TempEffectGPP.ToptTEM ,1,info.Forcing.Size(2)) ).^2),0);

end
function [fe,fx,d,p]=Prec_TempEffectGPP_TEM(f,fe,fx,s,d,p,info);


  term1 = f.TairDay - repmat( p.TempEffectGPP.Tmin ,1,info.forcing.size(2));
  term2 = f.TairDay - repmat( p.TempEffectGPP.Tmax ,1,info.forcing.size(2));
  
  d.TempEffectGPP.TempScGPP = max(term1.*term2 ./ ((term1.*term2) - ( f.TairDay - repmat( p.TempEffectGPP.Topt ,1,info.forcing.size(2)) ).^2),0);

end
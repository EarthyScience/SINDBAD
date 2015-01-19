function [fe,fx,d,p] = Prec_TempEffectGPP_TEM(f,fe,fx,s,d,p,info)

tmp     = ones(1,info.forcing.size(2));
term1   = f.TairDay - (p.TempEffectGPP.Tmin * tmp);
term2   = f.TairDay - (p.TempEffectGPP.Tmax * tmp);
pTopt   = p.TempEffectGPP.Topt * tmp;
pTScGPP = term1 .* term2 ./ ((term1 .* term2) - (f.TairDay - pTopt) .^ 2);

d.TempEffectGPP.TempScGPP   = max(pTScGPP,0);

end
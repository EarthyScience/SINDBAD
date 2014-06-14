function [fe,fx,d,p]=Prec_VPDEffectGPP_Medlyn(f,fe,fx,s,d,p,info);

%proposed by Wang-Prentice

%calculate co2 compensation point after Bernacci (C3 photosynthesis)
Tparam=0.0512;
CompPointRef= 42.75;
CO2CompPoint = CompPointRef .* exp(Tparam .* ( f.TairDay - 25));

%calc ci according to medlyn
ci= f.ca .* p.Transp.g1 ./ ( p.Transp.g1 + sqrt( f.VPDDay ));

d.VPDEffectGPP.VPDScGPP = (ci-CO2CompPoint)./(ci+2.*CO2CompPoint);

end
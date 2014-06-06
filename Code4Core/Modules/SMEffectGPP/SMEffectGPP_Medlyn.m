function [fx,s,d]=SMEffectGPP_Medlyn(f,fe,fx,s,d,p,info,i);

%precomputed: AoE   	= ca .* PsurfDay  ./ (1.6 .* (VPDDay + g1 .* sqrt(VPDDay)));    

%g1 kPA^0.5 [0.9 7]; median ~3.5

%calc GPP supply
d.SMEffectGPP.gppS(:,i)   = d.SupplyTransp.TranspS(:,i) .* fe.AoE(:,i);   

%calc SM stress scalar
d.SMEffectGPP.SMScGPP(:,i)=min(d.TranspGPP.gppS(:,i)./d.DemandGPP.gppE(:,i),1);


end
function [fx,s,d] = SMEffectGPP_Medlyn(f,fe,fx,s,d,p,info,i)

%precomputed: AoE   	= ca .* PsurfDay  ./ (1.6 .* (VPDDay + g1 .* sqrt(VPDDay)));    

%g1 kPA^0.5 [0.9 7]; median ~3.5

%calc GPP supply
d.SMEffectGPP.gppS(:,i)   = d.SupplyTransp.TranspS(:,i) .* fe.SMEffectGPP.AoE(:,i);   

%calc SM stress scalar
ndx     = d.DemandGPP.gppE(:,i) > 0;
ndxn	= ~(d.DemandGPP.gppE(:,i) > 0);
d.SMEffectGPP.SMScGPP(ndx,i) = min( d.SMEffectGPP.gppS(ndx,i) ./ d.DemandGPP.gppE(ndx,i) ,1);
d.SMEffectGPP.SMScGPP(ndxn,i) = 0;

end
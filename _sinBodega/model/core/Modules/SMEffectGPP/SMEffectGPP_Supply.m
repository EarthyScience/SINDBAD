function [fx,s,d] = SMEffectGPP_Supply(f,fe,fx,s,d,p,info,i)
% #########################################################################
% PURPOSE	: Supply Control
% 
% REFERENCES:
% 
% CONTACT	: mjung, ncarval
% 
% INPUT
% 
% OUTPUT
% 
% DEPENDENCIES  :
% 
% NOTES:
% 
% #########################################################################

% calc GPP supply
d.SMEffectGPP.gppS(:,i)   = d.SupplyTransp.TranspS(:,i) .* d.WUE.AoE(:,i);   

% calc SM stress scalar
ndx                             = d.DemandGPP.gppE(:,i) > 0;
ndxn                            = ~(d.DemandGPP.gppE(:,i) > 0);
d.SMEffectGPP.SMScGPP(ndx,i)    = min( d.SMEffectGPP.gppS(ndx,i) ./ d.DemandGPP.gppE(ndx,i) ,1);
d.SMEffectGPP.SMScGPP(ndxn,i)	= 0;

end
function [f,fe,fx,s,d,p] = gppfwSoil_supply(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
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
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% calc GPP supply
d.gppfwSoil.gppS(:,tix)   = d.tranSup.tranSup(:,tix) .* d.WUE.AoE(:,tix);   

% calc SM stress scalar
ndx                             = d.gppDem.gppE(:,tix) > 0;
ndxn                            = ~(d.gppDem.gppE(:,tix) > 0);
d.gppfwSoil.SMScGPP(ndx,tix)    = min( d.gppfwSoil.gppS(ndx,tix) ./ d.gppDem.gppE(ndx,tix) ,1);
d.gppfwSoil.SMScGPP(ndxn,tix)	= 0;

end
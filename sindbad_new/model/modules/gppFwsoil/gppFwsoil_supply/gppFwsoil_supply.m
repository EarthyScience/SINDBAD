function [fx,s,d] = gppFwsoil_supply(f,fe,fx,s,d,p,info,tix)
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
d.gppFwsoil.gppS(:,tix)   = d.transpFwsoil.transpJactS(:,tix) .* d.wue.AoE(:,tix);   

% calc SM stress scalar
ndx                             = d.gppJdem.gppE(:,tix) > 0;
ndxn                            = ~(d.gppJdem.gppE(:,tix) > 0);
d.gppFwsoil.SMScGPP(ndx,tix)    = min( d.gppFwsoil.gppS(ndx,tix) ./ d.gppJdem.gppE(ndx,tix) ,1);
d.gppFwsoil.SMScGPP(ndxn,tix)	= 0;

end
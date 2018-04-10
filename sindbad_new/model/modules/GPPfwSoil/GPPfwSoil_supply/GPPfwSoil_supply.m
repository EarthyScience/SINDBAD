function [fx,s,d] = GPPfwSoil_supply(f,fe,fx,s,d,p,info,tix)
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
d.GPPfwSoil.gppS(:,tix)   = d.TranfwSoil.TranActS(:,tix) .* d.WUE.AoE(:,tix);   

% calc SM stress scalar
ndx                             = d.GPPdem.gppE(:,tix) > 0;
ndxn                            = ~(d.GPPdem.gppE(:,tix) > 0);
d.GPPfwSoil.SMScGPP(ndx,tix)    = min( d.GPPfwSoil.gppS(ndx,tix) ./ d.GPPdem.gppE(ndx,tix) ,1);
d.GPPfwSoil.SMScGPP(ndxn,tix)	= 0;

end
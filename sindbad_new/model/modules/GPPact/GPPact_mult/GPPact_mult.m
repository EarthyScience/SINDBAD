function [fx,s,d] = GPPact_mult(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% FUNCTION	: 
% 
% PURPOSE	: 
% 
% REFERENCES:
% 
% CONTACT	: mjung, ncarval
% 
% INPUT     :
% FAPAR     : fraction of absorbed photosynthetically active radiation
%           [] (equivalent to "canopy cover" in Gash and Miralles)
%           (f.FAPAR)
% rueGPP    : maximum instantaneous radiation use efficiency [gC/MJ]
%           (d.GPPpot.rueGPP)
% PAR       : photosynthetically active radiation [MJ/m2/time]
%           (f.PAR)
% FAPAR     : fraction of absorbed photosynthetically active radiation
%           [] (equivalent to "canopy cover" in Gash and Miralles)
%           (f.FAPAR)
% AllScGPP  : 
% SMScGPP
% 
% OUTPUT    :
% AllScGPP
% gpp
% 
% DEPENDENCIES  :
% 
% NOTES: we don't actually need FAPAR, rueGPP, PAR. ---
% 
% #########################################################################

% calculate the combined effect of all the stress scalars from demand GPP
% and the supply GPP 
d.GPPact.AllScGPP(:,tix)	= d.GPPdem.AllDemScGPP(:,tix) .* d.GPPfwSoil.SMScGPP(:,tix);

% multiply GPPdem with soil moisture sress scaler (is the same as taking
% the min of GPPdem and SupplyGPP)
fx.gpp(:,tix) = d.GPPdem.gppE(:,tix) .* d.GPPfwSoil.SMScGPP(:,tix);


end
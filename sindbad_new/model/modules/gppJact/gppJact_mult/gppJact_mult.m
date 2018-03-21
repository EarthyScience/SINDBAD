function [fx,s,d] = gppJact_mult(f,fe,fx,s,d,p,info,tix)
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
%           (d.gppJruemax.rueGPP)
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
d.gppJact.AllScGPP(:,tix)	= d.gppJdem.AllDemScGPP(:,tix) .* d.gppFwsoil.SMScGPP(:,tix);

% multiply gppJdem with soil moisture sress scaler (is the same as taking
% the min of gppJdem and SupplyGPP)
fx.gpp(:,tix) = d.gppJdem.gppE(:,tix) .* d.gppFwsoil.SMScGPP(:,tix);


end
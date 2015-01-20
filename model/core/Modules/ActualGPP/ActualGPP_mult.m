function [fx,s,d] = ActualGPP_mult(f,fe,fx,s,d,p,info,i)
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
%           (d.RdiffEffectGPP.rueGPP)
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
% NOTES:
% 
% #########################################################################

% calculate the combined effect of all the stress scalars from demand GPP
% and the supply GPP 
d.ActualGPP.AllScGPP(:,i)	= d.DemandGPP.AllScGPP(:,i) .* d.SMEffectGPP.SMScGPP(:,i);

% multiply DemandGPP with soil moisture sress scaler (is the same as taking
% the min of DemandGPP and SupplyGPP)
fx.gpp(:,i) = d.DemandGPP.gppE(:,i) .* d.SMEffectGPP.SMScGPP(:,i);


end
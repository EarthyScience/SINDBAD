function [fx,s,d] = gppJact_min(f,fe,fx,s,d,p,info,i)
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
%           (d.MaxRUE.rueGPP)
% PAR       : photosynthetically active radiation [MJ/m2/time]
%           (f.PAR)
% FAPAR     : fraction of absorbed photosynthetically active radiation
%           [] (equivalent to "canopy cover" in Gash and Miralles)
%           (f.FAPAR)
% AllScGPP
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

% calculate the minimum of all the stress scalars from demand GPP and the
% supply GPP
d.ActualGPP.AllScGPP(:,i)	= min(d.DemandGPP.AllDemScGPP(:,i),d.SMEffectGPP.SMScGPP(:,i));

% ... and multiply with apar and rue
fx.gpp(:,i) = f.FAPAR(:,i) .* f.PAR(:,i) .* d.MaxRUE.rueGPP(:,i) .* d.ActualGPP.AllScGPP(:,i);

end
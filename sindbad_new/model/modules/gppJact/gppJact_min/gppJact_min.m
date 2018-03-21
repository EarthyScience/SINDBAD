function [fx,s,d] = gppJact_min(f,fe,fx,s,d,p,info,tix)
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
d.gppJact.AllScGPP(:,tix)	= min(d.gppJdem.AllDemScGPP(:,tix),d.gppFwsoil.SMScGPP(:,tix));

% ... and multiply with apar and rue
fx.gpp(:,tix) = f.FAPAR(:,tix) .* f.PAR(:,tix) .* d.gppJruemax.rueGPP(:,tix) .* d.gppJact.AllScGPP(:,tix);

end
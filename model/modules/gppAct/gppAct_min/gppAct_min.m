function [f,fe,fx,s,d,p] = gppAct_min(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% FUNCTION    : 
% 
% PURPOSE    : 
% 
% REFERENCES:
% 
% CONTACT    : mjung, ncarval
% 
% INPUT     :
% FAPAR     : fraction of absorbed photosynthetically active radiation
%           [] (equivalent to "canopy cover" in Gash and Miralles)
%           (s.cd.fAPAR)
% rueGPP    : maximum instantaneous radiation use efficiency [gC/MJ]
%           (d.gppPot.rueGPP)
% PAR       : photosynthetically active radiation [MJ/m2/time]
%           (f.PAR)
% FAPAR     : fraction of absorbed photosynthetically active radiation
%           [] (equivalent to "canopy cover" in Gash and Miralles)
%           (s.cd.fAPAR)
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
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% calculate the minimum of all the stress scalars from demand GPP and the
% supply GPP
d.gppAct.AllScGPP(:,tix)    = minsb(d.gppDem.AllDemScGPP(:,tix),d.gppfwSoil.SMScGPP(:,tix));

% ... and multiply with apar and rue
fx.gpp(:,tix) = s.cd.fAPAR(:,tix) .* f.PAR(:,tix) .* d.gppPot.rueGPP(:,tix) .* d.gppAct.AllScGPP(:,tix);

end
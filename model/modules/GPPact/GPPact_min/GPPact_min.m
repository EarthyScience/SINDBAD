function [f,fe,fx,s,d,p] = GPPactmin(f,fe,fx,s,d,p,info,tix)
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
%           (d.GPPpot.rueGPP)
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
d.GPPact.AllScGPP(:,tix)    = minsb(d.GPPdem.AllDemScGPP(:,tix),d.GPPfwSoil.SMScGPP(:,tix));

% ... and multiply with apar and rue
fx.gpp(:,tix) = s.cd.fAPAR(:,tix) .* f.PAR(:,tix) .* d.GPPpot.rueGPP(:,tix) .* d.GPPact.AllScGPP(:,tix);

end
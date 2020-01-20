function [f,fe,fx,s,d,p] = gppAct_mult(f,fe,fx,s,d,p,info,tix)
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
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% calculate the combined effect of all the stress scalars from demand GPP
% and the supply GPP 
d.gppAct.AllScGPP(:,tix)    =   d.gppDem.AllDemScGPP(:,tix) .* d.gppfwSoil.SMScGPP(:,tix); %sujan
fx.gpp(:,tix)               = s.cd.fAPAR .* d.gppPot.gppPot(:,tix) .* d.gppAct.AllScGPP(:,tix);

end
function [f,fe,fx,s,d,p] = gppAct_min(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculate GPP based on minimum of demand stressors and soil moisture stressor
%
% Inputs:
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

%   - d.WUE.AoE: water use efficiency in gC/mmH2O
%   - d.tranSup.tranSup: supply limited transpiration
%   - d.gppDem.gppE: Demand-driven GPP with stressors except wSoil applied
%
% Outputs:
%   - fx.gpp: actual GPP 
%
% Modifies:
%   - 
%
% References:
%   - 
%
% Notes:
%   - 
%
% Created by:
%   - Sujan Koirala (skoirala)
%   - Martin Jung (mjung)
%
% Versions:
%   - 1.0 on 22.11.2019 (skoirala): 
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%

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
% ... and multiply
fx.gpp(:,tix)               = s.cd.fAPAR .* d.gppPot.gppPot(:,tix) .* d.gppAct.AllScGPP(:,tix);


end
function [f,fe,fx,s,d,p] = gppAct_min(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% compute the actual GPP with potential scaled by minimum stress scalar of demand 
% and supply for uncoupled model structure (no coupling with transpiration)
%
% Inputs:
%   - s.cd.fAPAR: fraction of absorbed photosynthetically active radiation
%           [-] (equivalent to "canopy cover" in Gash and Miralles) 
%   - d.gppPot.gppPot: maximum potential GPP based on radiation use efficiency
%   - d.gppDem.AllDemScGPP: effective demand scalars, between 0-1
%   - d.gppfwSoil.SMScGPP: soil moisture stress scalar, between 0-1
% 
% Outputs:
%   - fx.gpp: actual GPP [gC/m2/time]
%
% Modifies:
%   - d.gppAct.AllScGPP
%
% References:
%   - 
%
% Notes:
%   -
% 
% Created by:
%   - Nuno Carvalhais (ncarval)
%
% Versions:
%   - 1.0 on 22.11.2019 (skoirala): documentation and clean up 
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
d.gppAct.AllScGPP(:,tix)    = min(d.gppDem.AllDemScGPP(:,tix),d.gppfwSoil.SMScGPP(:,tix));
% ... and multiply
fx.gpp(:,tix)               = s.cd.fAPAR .* d.gppPot.gppPot(:,tix) .* d.gppAct.AllScGPP(:,tix);


end
function [f,fe,fx,s,d,p] = tranSup_wAWCvegFrac(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculate the supply limited transpiration as the minimum of fraction of total AWC
% and the actual available moisture, scaled by vegetated fractions
%
% Inputs:
%   - s.w.wSoil : total soil moisture
%   - s.wd.pawAct: actual extractable water
%   - s.wd.p_wSoilBase_wAWC: total maximum plant available water (FC-WP)
%   - s.cd.vegFrac: vegetation fraction
%
% Outputs:
%   - d.tranSup.tranSup: supply limited transpiration 
%
% Modifies:
%   - 
%
% References:
%   - 
%
% Notes:
%   - Assumes that the transpiration supply scales with vegetated fraction
%
% Created by:
%   - Sujan Koirala (skoirala)
%
% Versions:
%   - 1.0 on 22.11.2019 (skoirala): 
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
d.tranSup.tranSup(:,tix)     =   sum(s.wd.pawAct,2) .* p.tranSup.tranFrac .* s.cd.vegFrac;
end

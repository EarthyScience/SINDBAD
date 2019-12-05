function [f,fe,fx,s,d,p] = prec_WUE_VPDDay(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculates the WUE/AOE as a function of WUE at 1hpa daily mean VPD 
%
% Inputs:
%    - p.WUE.WUEat1hPa: the VOD at 1 hpa 
%
% Outputs:
%   - d.WUE.AoE: water use efficiency - ratio of assimilation and
%           transpiration fluxes [gC/mmH2O]
%
% Modifies:
%     - None
%
% References:
%    - 
%
% Created by:
%   - Sujan Koirala (skoirala)
%   - Jake Nelson (jnelson): for the typical values and ranges of WUEat1hPa
%            across fluxNet sites
%
% Versions:
%   - 1.0 on 11.11.2019 (skoirala):
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%% 
d.WUE.AoE                   =  p.WUE.WUEat1hPa * 1 ./ sqrt(f.VPDDay);
end
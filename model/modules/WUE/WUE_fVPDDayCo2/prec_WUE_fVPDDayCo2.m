function [f,fe,fx,s,d,p] = prec_WUE_VPDDayCo2(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculates the WUE/AOE as a function of WUE at 1hpa daily mean VPD 
%
% Inputs:
%    - p.WUE.WUEat1hPa: the VPD at 1 hpa 
%    - f.VPDDay: daytime mean VPD [kPa] 
%
% Outputs:
%   - fe.WUE.AoENoCO2: water use efficiency - ratio of assimilation and
%           transpiration fluxes [gC/mmH2O] without co2 effect
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
% "p.WUE.WUEat1hPa"

kpa_to_hpa  = 10;
fe.WUE.AoENoCO2   = p.WUE.WUEatOnehPa .* 1 ./ sqrt(kpa_to_hpa .* (f.VPDDay +0.05));
end
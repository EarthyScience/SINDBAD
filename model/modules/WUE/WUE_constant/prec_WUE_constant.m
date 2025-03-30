function [f,fe,fx,s,d,p]=prec_WUE_constant(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculates the WUE/AOE as a constant in space and time 
%
% Inputs:
%    - p.WUE.constantWUE: the constant value
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
%   - Jake Nelson (jnelson): for the typical values and ranges of WUE across fluxNet
%                            sites
%
% Versions:
%   - 1.0 on 11.11.2019 (skoirala):
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%% 
d.WUE.AoE = info.tem.helpers.arrays.onespixtix .* p.WUE.constantWUE;    
end
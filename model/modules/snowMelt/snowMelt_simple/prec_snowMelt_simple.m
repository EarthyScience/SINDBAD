function [f,fe,fx,s,d,p] = prec_snowMelt_simple(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% precomputes the snow melt term as function of f.Tair
%
% Inputs:
%	-  f.Tair:  temperature [C]
%   -  p.snowMelt.rate: snow melt rate [mm/C/day]
%   -  info.tem.model.time.nStepsDay: model time steps per day
%
% Outputs:
%   - fe.snowMelt.Tterm: effect of temperature on snow melt [mm/time]
%
% Modifies:
% 	- 
%
% References:
%	- 
%
% Notes:
%   -  may not be working well for longer time scales (like for weekly or
%       longer time scales). Warnings needs to be set accordingly.
% 
% Created by:
%   - Martin Jung (mjung)
%
% Versions:
%   - 1.0 on 18.11.2019 (ttraut): cleaned up the code
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
% effect of temperature on snow melt = snowMeltRate .* Tair
pRate               = (p.snowMelt.rate .* info.tem.model.time.nStepsDay) .* info.tem.helpers.arrays.onestix;
fe.snowMelt.Tterm      = max(pRate .* f.Tair,0);

end

function [f,fe,fx,s,d,p] = prec_Qsnow_simple(f,fe,fx,s,d,p,info)
% #########################################################################
% precomputes the snow melt term as function of f.Tair
% Inputs:
%	-  f.Tair:  temperature [C]
%   -  p.Qsnow.rate: snow melt rate [mm/C/day]
%   -  info.tem.model.time.nStepsDay: model time steps per day
%
% Outputs:
%   - fe.Qsnow.Tterm: effect of temperature on snow melt [mm/time]
%
% Modifies:
% 	- 
%
% References:
%	- 
%
% Created by:
%   - Martin Jung (mjung@bgc-jena.mpg.de)
%
% Versions:
%   - 1.0 on 18.11.2019 (ttraut): cleaned up the code
%
% Notes:
%   -  may not be working well for longer time scales (like for weekly or
%       longer time scales). Warnings needs to be set accordingly.
%% 
% #########################################################################

% effect of temperature on snow melt = QsnowRate * Tair
pRate               = (p.Qsnow.rate .* info.tem.model.time.nStepsDay) * info.tem.helpers.arrays.onestix;
fe.Qsnow.Tterm      = max(pRate .* f.Tair,0);

end
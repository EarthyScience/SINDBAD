function [f,fe,fx,s,d,p] = dyna_Qsnow_simple(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% computes the snow melt term as function of f.Tair
% Inputs:
%   - fe.Qsnow.Tterm: effect of temperature on snow melt [mm/time]
%   - s.wd.wSnowFrac: snow cover fraction [-]
%   -  info.tem.model.time.nStepsDay: model time steps per day
%
% Outputs:
%   - fx.Qsnow: snow melt [mm/time]
%
% Modifies:
% 	- s.w.wSnow: water storage [mm]
%   - s.wd.WBP: water balance pool [mm]
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

% snow melt (mm/day) is calculated as a simple function of temperature
% and scaled with the snow covered fraction
fx.Qsnow(:,tix) = min( s.w.wSnow , fe.Qsnow.Tterm(:,tix) .* s.wd.wSnowFrac );

% update the snow pack
s.w.wSnow = s.w.wSnow - fx.Qsnow(:,tix);

% a Water Balance Pool variable that tracks how much water is still
% 'available'
s.wd.WBP  = s.wd.WBP + fx.Qsnow(:,tix);


end
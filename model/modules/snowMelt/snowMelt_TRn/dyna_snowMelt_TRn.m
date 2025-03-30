function [f,fe,fx,s,d,p] = dyna_snowMelt_TRn(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% precompute the potential snow melt based on temperature and net radiation
% on days with Tair > 0 degC
%
% Inputs:
%   - fe.snowMelt.potMelt 	: potential snow melt based on temperature and net radiation [mm/time]
% 	- s.wd.wSnowFrac    : snow cover fraction []
%	- info structure
%
% Outputs:
%   - fx.snowMelt     : snow melt [mm/time]
%
% Modifies:
% 	- s.w.wSnow    : snowpack [mm]
% 	- s.wd.WBP     : water balance pool [mm] 
%
% References:
%	- 
%
% Created by:
%   - Tina Trautmann (ttraut)
%
% Versions:
%   - 1.0 on 18.11.2019 (ttraut): cleaned up the code
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
% Then snow melt (mm/day) is calculated as a simple function of temperature and radiation
% and scaled with the snow covered fraction
fx.snowMelt(:,tix) = min( s.w.wSnow , fe.snowMelt.potMelt(:,tix) .* s.wd.wSnowFrac);

% update the snow pack
s.w.wSnow = s.w.wSnow - fx.snowMelt(:,tix);

% a Water Balance Pool variable that tracks how much water is still
% 'available'
s.wd.WBP = s.wd.WBP + fx.snowMelt(:,tix);


end

function [f,fe,fx,s,d,p] = wSnowFrac_HTESSEL(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% computes the snow pack and fraction of snow cover following the HTESSEL
% approach
%
% Inputs:
%	- fe.rainSnow.snow:         snowfall
%	- p.wSnowFrac.CoverParam:   snow cover parameter; snow amount that
%	ensures full coverage of the grid cell [mm]
%
% Outputs:
%   - fx.evapSoil: soil evaporation flux
%
% Modifies:
% 	- s.w.wSnow:        adds snow fall to the snow pack
% 	- s.wd.wSnowFrac:   updates snow cover fraction
%
% References:
%	- H-TESSEL = land surface scheme of the European Centre for Medium-
%       Range Weather Forecasts' operational weather forecast system; 
%       Balsamo et al., 2009
%
% Created by:
%   - Martin Jung (mjung)
%
% Versions:
%   - 1.0 on 18.11.2019 (ttraut): cleaned up the code
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
% first update the snow pack
s.w.wSnow       = s.w.wSnow + fe.rainSnow.snow(:,tix);

% suggested by Sujan (after HTESSEL GHM)
s.wd.wSnowFrac = min(1, s.w.wSnow ./ p.wSnowFrac.CoverParam );

end

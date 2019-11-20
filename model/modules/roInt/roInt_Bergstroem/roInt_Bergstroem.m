function [f,fe,fx,s,d,p] = roInt_Bergstroem(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% calculates land surface runoff and infiltration
%
% Inputs:
% fe.rainSnow.rain            : rain fall [mm/time]
% fx.snowMelt          : snow melt [mm/time]
%	- p.roInt.smaxberg   : shape parameter of runoff-infiltration curve []
%   - p.roInt.smax 		: maximum woil water holding capacity [mm]

%
% Outputs:
%   - fx.roInt      : runoff from land [mm/time]
%
% Modifies:
% 	- s.w.wSoil    : total soil moisture [mm]
%   - s.wd.WBP     : water balance pool [mm]

%
% References:
%	- Bergstroem 1992
%
% Created by:
%   - Tina Trautmann (ttraut@bgc-jena.mpg.de)
%
% Versions:
%   - 1.0 on 18.11.2019 (ttraut): cleaned up the code
%%
% #########################################################################

% calculate land runoff from incoming water and current soil moisture
% (fe.rainSnow.rain(:,tix)+fx.snowMelt(:,tix)) = WBP
fx.roInt(:,tix)  = (fe.rainSnow.rain(:,tix)+fx.snowMelt(:,tix)) .* exp(p.roInt.berg .* log(s.w.wSoil./p.roInt.smax));

% update soil moisture
s.w.wSoil       = s.w.wSoil + ((fe.rainSnow.rain(:,tix)+fx.snowMelt(:,tix))-fx.roInt(:,tix));

% account for oversaturation (in TWS paper after subtracting of ET)
tmp             = max(0,s.w.wSoil-p.roInt.smax);
s.w.wSoil       = s.w.wSoil - tmp;
fx.roInt(:,tix)  = fx.roInt(:,tix) + tmp;

% update water balance
s.wd.WBP        = s.wd.WBP - fx.roInt(:,tix);

end

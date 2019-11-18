function [f,fe,fx,s,d,p] = Qint_Bergstroem(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% calculates land surface runoff and infiltration
%
% Inputs:
% fe.rainSnow.rain            : rain fall [mm/time]
% fx.Qsnow          : snow melt [mm/time]
%	- p.Qint.smaxberg   : shape parameter of runoff-infiltration curve []
%   - p.Qint.smax 		: maximum woil water holding capacity [mm]

%
% Outputs:
%   - fx.Qint      : runoff from land [mm/time]
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
% (fe.rainSnow.rain(:,tix)+fx.Qsnow(:,tix)) = WBP
fx.Qint(:,tix)  = (fe.rainSnow.rain(:,tix)+fx.Qsnow(:,tix)) .* exp(p.Qint.berg .* log(s.w.wSoil./p.Qint.smax));

% update soil moisture
s.w.wSoil       = s.w.wSoil + ((fe.rainSnow.rain(:,tix)+fx.Qsnow(:,tix))-fx.Qint(:,tix));

% account for oversaturation (in TWS paper after subtracting of ET)
tmp             = max(0,s.w.wSoil-p.Qint.smax);
s.w.wSoil       = s.w.wSoil - tmp;
fx.Qint(:,tix)  = fx.Qint(:,tix) + tmp;

% update water balance
s.wd.WBP        = s.wd.WBP - fx.Qint(:,tix);

end

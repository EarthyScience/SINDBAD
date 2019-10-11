function [f,fe,fx,s,d,p] = Qint_Bergstroem(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: calculates land surface runoff and infiltration
%
% REFERENCES: Bergstroem 1992
%
% CONTACT	: ttraut
%
% INPUT
% f.Rain            : rain fall [mm/time]
% fx.Qsnow          : snow melt [mm/time]
% p.Qint.smaxberg   : shape parameter of runoff-infiltration curve []
% p.Qint.smax 		: maximum woil water holding capacity [mm]
% s.w.wSoil         : total soil moisture [mm]
% s.wd.WBP          : water balance pool [mm]
%
% OUTPUT
% fx.Qint      : runoff from land [mm/time]
% s.w.wSoil    : total soil moisture [mm]
% s.wd.WBP     : water balance pool [mm]
%
% NOTES:
%
% #########################################################################

% calculate land runoff from incoming water and current soil moisture
fx.Qint(:,tix)  = (f.Rain(:,tix)+fx.Qsnow(:,tix)) .* exp(p.Qint.berg .* log(s.w.wSoil./p.Qint.smax));
% original formula:
% fx.Qint(:,tix)  = (f.Rain(:,tix)+fx.Qsnow(:,tix)) .* (s.w.wSoil./p.Qint.smax).^p.Qint.berg;

% update soil moisture
s.w.wSoil       = s.w.wSoil + ((f.Rain(:,tix)+fx.Qsnow(:,tix))-fx.Qint(:,tix));

% account for oversaturation (in TWS paper after subtracting of ET)
tmp             = max(0,s.w.wSoil-p.Qint.smax);
s.w.wSoil       = s.w.wSoil - tmp;
fx.Qint(:,tix)  = fx.Qint(:,tix) + tmp;

% update water balance
s.wd.WBP        = s.wd.WBP - fx.Qint(:,tix);

end

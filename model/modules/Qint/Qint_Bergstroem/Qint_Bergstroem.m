function [f,fe,fx,s,d,p] = Qint_Bergstroem(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: calculates land surface runoff and infiltration
% 
% REFERENCES: Bergstroem 1992
% 
% CONTACT	: ttraut
% 
% INPUT
% Rain 		: rain fall [mm/time]
%			(f.Rain)
% Qsnow 	: snow melt [mm/time]
% 			(fx.Qsnow)
% berg      : shape parameter of runoff-infiltration curve []
%           (p.Qint.berg)
% smax 		: maximum woil water holding capacity [mm]
% 			(p.pSoil.smax)
% wSM      	: total soil moisture [mm]
% 			(s.w.wSoil)
% WBP       : water balance pool [mm]
%           (s.wd.WBP)
% 
% OUTPUT
% Qint      : runoff from land [mm/time]
%           (fx.Qint)
% wSM      	: total soil moisture [mm]
% 			(s.w.wSoil)
% WBP       : water balance pool [mm]
%           (s.wd.WBP)
% 
% NOTES: naming of rainfall/snow melt, rain fall as fx or as fe or f?
% 	 	 update water balance?
% 
% #########################################################################

% calculate land runoff from incoming water and current soil moisture
fx.Qint(:,tix) = (f.Rain(:,tix)+fx.Qsnow(:,tix)) .* exp(p.Qint.berg .* log(s.w.wSoil./p.Qint.smax));

% update soil moisture 
s.w.wSoil = s.w.wSoil + ((f.Rain(:,tix)+fx.Qsnow(:,tix))-fx.Qint(:,tix));

% account for oversaturation (in TWS paper after subtracting of ET)
tmp             = max(0,s.w.wSoil-p.Qint.smax); 
s.w.wSoil       = s.w.wSoil - tmp;
fx.Qint(:,tix)  = fx.Qint(:,tix) + tmp;

% update water balance
s.wd.WBP = s.wd.WBP - fx.Qint(:,tix);

end

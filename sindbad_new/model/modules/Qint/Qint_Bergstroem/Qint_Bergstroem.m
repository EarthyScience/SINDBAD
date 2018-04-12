function [f,fe,fx,s,d,p] = Qint_Bergstroem(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: calculates land surface runoff and infiltration
% 
% REFERENCES: Bergström 1992
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
% smax 		: maximum woil wate rholding capacity [mm]
% 			(p.psoil.smax)
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

% update soil moisture and water balance
s.w.wSoil = s.w.wSoil + ((f.Rain(:,tix)+fx.Qsnow(:,tix))-fx.Qint(:,tix));

s.wd.WBP = s.wd.WBP - fx.Qint(:,tix);

end

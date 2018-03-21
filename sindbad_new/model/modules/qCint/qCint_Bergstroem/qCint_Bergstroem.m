function [fx,s,d] = qCint_Bergstroem(f,fe,fx,s,d,p,info,tix)
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
%           (p.qCint.berg)
% smax 		: maximum woil wate rholding capacity [mm]
% 			(p.psoilR.smax)
% wSM      	: total soil moisture [mm]
% 			(s.wSM)
% WBP       : water balance pool [mm]
%           (d.Temp.WBP)
% 
% OUTPUT
% Qint      : runoff from land [mm/time]
%           (fx.Qint)
% wSM      	: total soil moisture [mm]
% 			(s.wSM)
% WBP       : water balance pool [mm]
%           (d.Temp.WBP)
% 
% NOTES: naming of rainfall/snow melt, rain fall as fx or as fe or f?
% 	 	 update water balance?
% 
% #########################################################################

% calculate land runoff from incoming water and current soil moisture
fx.Qint(:,tix) = (f.Rain(:,tix)+fx.Qsnow(:,tix)) .* exp(p.qCint.berg .* log(s.wSM./p.qCint.smax));

% update soil moisture and water balance
s.wSM = s.wSM + ((f.Rain(:,tix)+fx.Qsnow(:,tix))-fx.Qint(:,tix));

d.Temp.WBP = d.Temp.WBP - fx.Qint(:,tix);

end

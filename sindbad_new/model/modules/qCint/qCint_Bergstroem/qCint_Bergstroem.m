function [fx,s,d] = qCint_Bergstroem(f,fe,fx,s,d,p,info,i)
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
%           (p.RunoffInt.berg)
% smax 		: maximum woil wate rholding capacity [mm]
% 			(p.SOIL.smax)
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
fx.Qint(:,i) = (f.Rain(:,i)+fx.Qsnow(:,i)) .* exp(p.RunoffInt.berg .* log(s.wSM./p.RunoffInt.smax));

% update soil moisture and water balance
s.wSM = s.wSM + ((f.Rain(:,i)+fx.Qsnow(:,i))-fx.Qint(:,i));

d.Temp.WBP = d.Temp.WBP - fx.Qint(:,i);

end

function [fx,s,d] = dyna_Qsnw_TRn(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: compute the snow melt based on radiation-temperature factors
% 
% REFERENCES: ??
% 
% CONTACT	: ttraut
% 
% INPUT
% Rain      : rainfall [mm/time]
%           (f.Rain)
% wSWE      : snowpack [mm]
%           (s.w.wSnow)
% potMelt 	: potential snow melt based on temperature and net radiation [mm/time]
%           (fe.Qsnw.potMelt)
% frSnow    : snow fraction [] 
%           (s.wd.wFrSnow)
% 
% OUTPUT
% Qsnow     : snow melt [mm/time]
%           (fx.Qsnow)
% wSWE      : snowpack [mm]
%           (s.w.wSnow)
% WBP       : water balance pool [mm]
%           (s.wd.WBP)
% 
% NOTES: 
% 
% #########################################################################

% Then snow melt (mm/day) is calculated as a simple function of temperature and radiation
% and scaled with the snow covered fraction
fx.Qsnow(:,tix) = min( s.w.wSnow , fe.Qsnw.potMelt(:,tix) .* s.wd.wFrSnow );

% update the snow pack
s.w.wSnow = s.w.wSnow - fx.Qsnow(:,tix);

% a Water Balance Pool variable that tracks how much water is still
% 'available'
s.wd.WBP = s.wd.WBP + fx.Qsnow(:,tix);


end

function [f,fe,fx,s,d,p] = dyna_Qsnow_simple(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: compute the snow melt
% 
% REFERENCES: ??
% 
% CONTACT	: mjung
% 
% INPUT
% Rain      : rainfall [mm/time]
%           (f.Rain)
% wSWE      : snowpack [mm]
%           (s.w.wSnow)
% Tterm     : effect of temperature on snow melt [mm/time]
%           (fe.Qsnow.Tterm)
% frSnow    : snow fraction [] (dimensionless)
%           (s.wd.wSnowFrac)
% 
% OUTPUT
% Qsnow     : snow melt [mm/time]
%           (fx.Qsnow)
% WBP       : water balance pool [mm]
%           (s.wd.WBP)
% 
% NOTES: 
% 
% #########################################################################

% Then snow melt (mm/day) is calculated as a simple function of temperature
% and scaled with the snow covered fraction
fx.Qsnow(:,tix) = min( s.w.wSnow , fe.Qsnow.Tterm(:,tix) .* s.wd.wSnowFrac );

% update the snow pack
s.w.wSnow = s.w.wSnow - fx.Qsnow(:,tix);

% a Water Balance Pool variable that tracks how much water is still
% 'available'
s.wd.WBP = s.wd.WBP + fx.Qsnow(:,tix);


end
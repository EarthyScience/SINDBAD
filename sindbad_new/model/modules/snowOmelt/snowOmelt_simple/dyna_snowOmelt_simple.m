function [fx,s,d] = dyna_snowOmelt_simple(f,fe,fx,s,d,p,info,tix)
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
%           (s.wSWE)
% Tterm     : effect of temperature on snow melt [mm/time]
%           (fe.snowOmelt.Tterm)
% frSnow    : snow fraction [] (dimensionless)
%           (s.wFrSnow)
% 
% OUTPUT
% Qsnow     : snow melt [mm/time]
%           (fx.Qsnow)
% WBP       : water balance pool [mm]
%           (d.Temp.WBP)
% 
% NOTES: 
% 
% #########################################################################

% Then snow melt (mm/day) is calculated as a simple function of temperature
% and scaled with the snow covered fraction
fx.Qsnow(:,tix) = min( s.wSWE , fe.snowOmelt.Tterm(:,tix) .* s.wFrSnow );

% update the snow pack
s.wSWE = s.wSWE - fx.Qsnow(:,tix);

% a Water Balance Pool variable that tracks how much water is still
% 'available'
d.Temp.WBP = d.Temp.WBP + fx.Qsnow(:,tix);


end
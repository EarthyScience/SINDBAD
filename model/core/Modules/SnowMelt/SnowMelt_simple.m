function [fx,s,d]=SnowMelt_simple(f,fe,fx,s,d,p,info,i);
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
%           (fe.SnowMelt.Tterm)
% frSnow    : snow fraction [] (dimensionless)
%           (d.SnowCover.frSnow)
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
fx.Qsnow(:,i) = min( s.wSWE(:,i) , fe.SnowMelt.Tterm(:,i) .* d.SnowCover.frSnow(:,i) );

% update the snow pack
s.wSWE(:,i) = s.wSWE(:,i) - fx.Qsnow(:,i);

% a Water Balance Pool variable that tracks how much water is still
% 'available'
d.Temp.WBP = d.Temp.WBP + fx.Qsnow(:,i);

end
function [fx,s,d] = SnowMelt_TRn(f,fe,fx,s,d,p,info,i)
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
%           (s.wSWE)
% potMelt 	: potential snow melt based on temperature and net radiation [mm/time]
%           (fe.SnowMelt.potMelt)
% frSnow    : snow fraction [] 
%           (s.wFrSnow)
% 
% OUTPUT
% Qsnow     : snow melt [mm/time]
%           (fx.Qsnow)
% wSWE      : snowpack [mm]
%           (s.wSWE)
% WBP       : water balance pool [mm]
%           (d.Temp.WBP)
% 
% NOTES: 
% 
% #########################################################################

% Then snow melt (mm/day) is calculated as a simple function of temperature and radiation
% and scaled with the snow covered fraction
fx.Qsnow(:,i) = min( s.wSWE , fe.SnowMelt.potMelt(:,i) .* s.wFrSnow );

% update the snow pack
s.wSWE = s.wSWE - fx.Qsnow(:,i);

% a Water Balance Pool variable that tracks how much water is still
% 'available'
d.Temp.WBP = d.Temp.WBP + fx.Qsnow(:,i);


end

function [fx,s,d] = dyna_snowOmelt_TRn(f,fe,fx,s,d,p,info,tix)
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
%           (fe.snowOmelt.potMelt)
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
fx.Qsnow(:,tix) = min( s.wSWE , fe.snowOmelt.potMelt(:,tix) .* s.wFrSnow );

% update the snow pack
s.wSWE = s.wSWE - fx.Qsnow(:,tix);

% a Water Balance Pool variable that tracks how much water is still
% 'available'
d.Temp.WBP = d.Temp.WBP + fx.Qsnow(:,tix);


end

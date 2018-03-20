function [fx,s,d] = wsurfOsatfrac_WTD(f,fe,fx,s,d,p,info,i)
% #########################################################################
% PURPOSE	: 
% 
% REFERENCES: ??
% 
% CONTACT	: mjung
% 
% INPUT
% wWTD      : water table depth [m]
%           (s.wWTD)
% meanElev  : mean elevation [m]
%           (p.Terrain.meanElev)
% percElev  : pdf of the elevation [m] dimensions must be [nspace 100] 
%           (p.Terrain.percElev)
% CritDepth : critical depth [m]. should be a global variable; maybe 0.5
%           (i.e. where wtd is less than 0.5 m is considered saturated) 
%           (p.SaturatedFraction.CritDepth)
% 
% OUTPUT
% frSat     : saturated fraction of soil [] (from 0 to 1)
%           (s.wFrSat)
% 
% NOTES: NOT TESTED!!! 
% 
% #########################################################################

sc = s.wWTD ./ p.Terrain.meanElev;
dum = p.Terrain.percElev.*sc <= p.SaturatedFraction.CritDepth;
s.wFrSat = sum(dum,3)./100;

end
function [fx,s,d] = wSoilSatFr_WTD(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: 
% 
% REFERENCES: ??
% 
% CONTACT	: mjung
% 
% INPUT
% WTD      : water table depth [m]
%           (s.wd.WTD)
% meanElev  : mean elevation [m]
%           (p.ptopo.meanElev)
% percElev  : pdf of the elevation [m] dimensions must be [nspace 100] 
%           (p.ptopo.percElev)
% CritDepth : critical depth [m]. should be a global variable; maybe 0.5
%           (i.e. where wtd is less than 0.5 m is considered saturated) 
%           (p.wSoilSatFr.CritDepth)
% 
% OUTPUT
% frSat     : saturated fraction of soil [] (from 0 to 1)
%           (s.wd.wFrSat)
% 
% NOTES: NOT TESTED!!! 
% 
% #########################################################################

sc = s.wd.WTD ./ p.ptopo.meanElev;
dum = p.ptopo.percElev.*sc <= p.wSoilSatFr.CritDepth;
s.wd.wFrSat = sum(dum,3)./100;

end
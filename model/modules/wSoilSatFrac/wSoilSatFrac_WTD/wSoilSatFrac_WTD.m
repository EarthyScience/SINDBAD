function [f,fe,fx,s,d,p] = wSoilSatFrac_WTD(f,fe,fx,s,d,p,info,tix)
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
%           (p.pTopo.meanElev)
% percElev  : pdf of the elevation [m] dimensions must be [nspace 100] 
%           (p.pTopo.percElev)
% CritDepth : critical depth [m]. should be a global variable; maybe 0.5
%           (i.e. where wtd is less than 0.5 m is considered saturated) 
%           (p.wSoilSatFrac.CritDepth)
% 
% OUTPUT
% frSat     : saturated fraction of soil [] (from 0 to 1)
%           (s.wd.wSoilSatFrac)
% 
% NOTES: NOT TESTED!!! 
% 
% #########################################################################

sc = s.wd.WTD ./ p.pTopo.meanElev;
dum = p.pTopo.percElev.*sc <= p.wSoilSatFrac.CritDepth;
s.wd.wSoilSatFrac = sum(dum,3)./100;

end
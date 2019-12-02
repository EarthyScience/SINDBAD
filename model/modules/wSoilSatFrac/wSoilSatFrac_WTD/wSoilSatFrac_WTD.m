function [f,fe,fx,s,d,p] = wSoilSatFrac_WTD(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% computes the saturated fraction as a function of water table depth and topography
%
% Inputs:
%	- s.wd.WTD: water table depth [m]
%	- p.pTopo.meanElev,p.pTopo.percElev: mean elevation, pdf of the elevation [m]
%   - p.wSoilSatFrac.CritDepth: should be a global variable; maybe 0.5
%           (i.e. where wtd is less than 0.5 m is considered saturated) 
%           (p.wSoilSatFrac.CritDepth)
%
% Outputs:
%   - s.wd.wSoilSatFrac: saturated fraction
%
% Modifies:
% 	- 
%
% References:
%	- 
%
% Created by:
%   - Martin Jung (mjung)
%
% Versions:
%   - 1.0 on 18.11.2019 (skoirala): clean up
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
sc = s.wd.WTD ./ p.pTopo.meanElev;
dum = p.pTopo.percElev.*sc <= p.wSoilSatFrac.CritDepth;
s.wd.wSoilSatFrac = sum(dum,3)./100;

end
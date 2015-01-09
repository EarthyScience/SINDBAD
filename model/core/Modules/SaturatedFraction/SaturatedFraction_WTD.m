function [fx,s,d]=SaturatedFraction_WTD(f,fe,fx,s,d,p,info,i);
%CritDepth [m] should be a global variable; maybe 0.5 (i.e. where wtd is
%less than 0.5 m is considered saturated)

sc = s.wWTD ./ p.Terrain.meanElev;
dum = p.Terrain.percElev.*sc <= p.SaturatedFraction.CritDepth;
d.SaturatedFraction.frSat(:,i) = sum(dum,3)./100;
end
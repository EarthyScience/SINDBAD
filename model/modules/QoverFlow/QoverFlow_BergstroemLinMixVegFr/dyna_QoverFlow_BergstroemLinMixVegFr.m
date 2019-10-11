function [f,fe,fx,s,d,p] = dyna_QoverFlow_BergstroemLinMixVegFr(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: calculates land surface runoff and infiltration to different soil layers
%
% REFERENCES: Bergstroem 1992
%
% CONTACT	: ttraut
%
% INPUT
% p.QoverFlow.berg_scaleV : scaling parameter to define p.berg from p.vegFr
%                           for vegetated fraction
% p.QoverFlow.berg_scaleS : scaling parameter to define p.berg from p.vegFr
%                           for non vegetated fraction
% p.QoverFlow.smaxberg   : shape parameter of runoff-infiltration curve []
% p.QoverFlow.smaxVeg 	 : maximum plant available soil water  [mm]
% p.QoverFlow.smax1      : maximum water capacity of first soil layer  [mm]
% s.w.wSoil         : soil moisture of the layers [mm]
% s.w.wTotalSoil    : total soil moisture [mm]
% s.wd.WBP          : water balance pool [mm]
%
% OUTPUT
% fx.QoverFlow   : runoff from land [mm/time]
% fx.InSoil1   : infiltration in first soil layer [mm/time]
% s.w.wSoil    : total soil moisture [mm]
% s.wd.WBP     : water balance pool [mm]
%
% NOTES:
%
% #########################################################################

% check the parameter values
%if p.QoverFlow.smax1 > p.QoverFlow.smaxVeg
%  error(['unvalid parameter values in QoverFlow_Bergstroem: smax1 > smaxVeg']);
%end

tmp_smaxVeg   = p.QoverFlow.smax1 + p.QoverFlow.smax2;
tmp_SoilTotal = sum(s.w.wSoil, 2);
% calculate land runoff from incoming water and current soil moisture
tmp_InfExFrac = min(exp(p.QoverFlow.berg(:,tix) .* log(tmp_SoilTotal  ./ tmp_smaxVeg)),1);
fx.QoverFlow(:,tix)  = s.wd.WBP .* tmp_InfExFrac;


% original formula:
% fx.Qint(:,tix)  = (f.Rain(:,tix)+fx.Qsnow(:,tix)) .* (s.w.wSoil./p.Qint.smax).^p.Qint.berg;

% update water balance
s.wd.WBP        = s.wd.WBP - fx.QoverFlow(:,tix);

% update soil moisture for 1st layer
fx.InSoil1(:,tix) = min(p.QoverFlow.smax1 - s.w.wSoil(:,1), s.wd.WBP);
s.w.wSoil(:,1)    = s.w.wSoil(:,1) + fx.InSoil1(:,tix);

s.wd.WBP    = s.wd.WBP - fx.InSoil1(:,tix);

% for deeper layers
for sl=2:size(s.w.wSoil,2)
  ip = min(p.QoverFlow.smax2  - s.w.wSoil(:,sl), s.wd.WBP);
  s.w.wSoil(:,sl) =  s.w.wSoil(:,sl) + ip;
  s.wd.WBP = s.wd.WBP - ip;
end


end

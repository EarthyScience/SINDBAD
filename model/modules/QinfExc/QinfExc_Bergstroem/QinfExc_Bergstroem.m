function [f,fe,fx,s,d,p] = QoverFlow_Bergstroem(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: calculates land surface runoff and infiltration to different soil layers
%
% REFERENCES: Bergstroem 1992
%
% CONTACT	: ttraut
%
% INPUT
% p.QinfExc.smaxberg   : shape parameter of runoff-infiltration curve []
% p.QinfExc.smaxVeg 		: maximum plant available soil water  [mm]
% p.QinfExc.smax1 		  : maximum water capacity of first soil layer  [mm]
% s.w.wSoil         : soil moisture of the layers [mm]
% s.w.wTotalSoil    : total soil moisture [mm]
% s.wd.WBP          : water balance pool [mm]
%
% OUTPUT
% fx.QinfExc   : runoff from land [mm/time]
% fx.InSoil1   : infiltration in first soil layer [mm/time]
% s.w.wSoil    : total soil moisture [mm]
% s.wd.WBP     : water balance pool [mm]
%
% NOTES:
%
% #########################################################################

% check the parameter values
%if p.QinfExc.smax1 > p.QinfExc.smaxVeg
%  error(['unvalid parameter values in QinfExc_Bergstroem: smax1 > smaxVeg']);
%end

tmp_smaxVeg   = p.QinfExc.smax1 + p.QinfExc.smax2;
tmp_SoilTotal = sum(s.w.wSoil, 2);
% calculate land runoff from incoming water and current soil moisture
tmp_InfExFrac = min(exp(p.QinfExc.berg .* log(tmp_SoilTotal  ./ tmp_smaxVeg)),1);
fx.QinfExc(:,tix)  = s.wd.WBP .* tmp_InfExFrac;

if isreal(fx.QinfExc(:,tix))==0
error(['complex at tix ' num2str(tix)])
end

% original formula:
% fx.Qint(:,tix)  = (f.Rain(:,tix)+fx.Qsnow(:,tix)) .* (s.w.wSoil./p.Qint.smax).^p.Qint.berg;

% update water balance
s.wd.WBP        = s.wd.WBP - fx.QinfExc(:,tix);

% update soil moisture for 1st layer
fx.InSoil1 (:,tix) = min(p.QinfExc.smax1 - s.w.wSoil(:,1), s.wd.WBP);
s.w.wSoil (:,1)    = s.w.wSoil(:,1) + fx.InSoil1(:,tix);

s.wd.WBP    = s.wd.WBP - fx.InSoil1(:,tix);

% for deeper layers
for sl=2:size(s.w.wSoil,2)
  ip = min(p.QinfExc.smax2  - s.w.wSoil(:,sl), s.wd.WBP);
  s.w.wSoil (:,sl) =  s.w.wSoil (:,sl) + ip;
  s.wd.WBP = s.wd.WBP - ip;
end



% account for oversaturation (in TWS paper after subtracting of ET)
%tmp             = max(0,s.w.wSoil-p.QinfExc.smax);
%s.w.wSoil       = s.w.wSoil - tmp;
%fx.QinfExc(:,tix)  = fx.QinfExc(:,tix) + tmp;



end

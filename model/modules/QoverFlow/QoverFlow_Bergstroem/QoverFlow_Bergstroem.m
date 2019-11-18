function [f,fe,fx,s,d,p] = QoverFlow_Bergstroem(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% calculates land surface runoff and infiltration to different soil layers
%
% Inputs:
%	- p.QoverFlow.berg       : shape parameter of runoff-infiltration curve []
%   - p.QoverFlow.smax2      : maximum water capacity of second soil layer  [mm]
%   - p.QoverFlow.smax1      : maximum water capacity of first soil layer  [mm]
%
% Outputs:
%   - fx.QoverFlow : runoff from land [mm/time]
%   - fx.InSoil    : infiltration in soil [mm/time]
%
% Modifies:
% 	- s.w.wSoil    : soil moisture of the layers [mm]
%   - s.wd.WBP     : water balance pool [mm]
%
% References:
%	- Bergstroem 1992
%
% Created by:
%   - Tina Trautmann (ttraut@bgc-jena.mpg.de)
%
% Versions:
%   - 1.0 on 18.11.2019 (ttraut): cleaned up the code
%%
% #########################################################################

% check the parameter values
%if p.QoverFlow.smax1 > p.QoverFlow.smaxVeg
%  error(['unvalid parameter values in QoverFlow_Bergstroem: smax1 > smaxVeg']);
%end

tmp_smaxVeg   = p.QoverFlow.smax1 + p.QoverFlow.smax2;
tmp_SoilTotal = sum(s.w.wSoil, 2);

% calculate land runoff from incoming water and current soil moisture
tmp_InfExFrac = min(exp(p.QoverFlow.berg .* log(tmp_SoilTotal  ./ tmp_smaxVeg)),1);
fx.QoverFlow(:,tix)  = s.wd.WBP .* tmp_InfExFrac;

% update water balance
s.wd.WBP        = s.wd.WBP - fx.QoverFlow(:,tix);

% update soil moisture for 1st layer
fx.InSoil(:,tix) = min(p.QoverFlow.smax1 - s.w.wSoil(:,1), s.wd.WBP);
s.w.wSoil(:,1)   = s.w.wSoil(:,1) + fx.InSoil(:,tix);

s.wd.WBP    = s.wd.WBP - fx.InSoil1(:,tix);

% realocate excess of 1st layer to deeper layers 
for sl=2:size(s.w.wSoil,2)
  ip = min(p.QoverFlow.smax2  - s.w.wSoil(:,sl), s.wd.WBP);
  s.w.wSoil(:,sl) =  s.w.wSoil(:,sl) + ip;
  s.wd.WBP = s.wd.WBP - ip;
end

end

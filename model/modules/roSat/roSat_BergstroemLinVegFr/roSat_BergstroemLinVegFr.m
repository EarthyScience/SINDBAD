function [f,fe,fx,s,d,p] = dyna_roSat_BergstroemLinVegFr(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% calculates land surface runoff and infiltration to different soil layers
%
% Inputs:
%	- p.roSat.berg       : shape parameter of runoff-infiltration curve []
%   - p.roSat.smax2      : maximum water capacity of second soil layer  [mm]
%   - p.roSat.smax1      : maximum water capacity of first soil layer  [mm]

%
% Outputs:
%   - fx.roSat : runoff from land [mm/time]
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
%   - 1.1 on 27.11.2019: skoirala: changed to handle any number of soil layers
%
% Versions:
%   - 1.0 on 18.11.2019 (ttraut): cleaned up the code
%%
% #########################################################################


tmp_smaxVeg         =   sum(s.wd.p_wSoilBase_wSat,2);
tmp_SoilTotal       =   sum(s.w.wSoil, 2);

%--> get the berg parameters according the vegetation fraction
p.roSat.berg_tmp    =   max(0.1, p.roSat.berg_scale  .* s.cd.vegFrac); % do this?

%--> calculate land runoff from incoming water and current soil moisture
tmp_SatExFrac       =   min(exp(p.roSat.berg_tmp .* log(tmp_SoilTotal  ./ tmp_smaxVeg)),1);
fx.roSat(:,tix)     =   s.wd.WBP .* tmp_SatExFrac;

%--> update water balance
s.wd.WBP            =   s.wd.WBP - fx.roSat(:,tix);

%--> update soil moisture for 1st layer
fx.InSoil(:,tix)    =   min(s.wd.p_wSoilBase_wSat(:,1) - s.w.wSoil(:,1), s.wd.WBP);
s.w.wSoil(:,1)      =   s.w.wSoil(:,1) + fx.InSoil(:,tix);

s.wd.WBP            =   s.wd.WBP - fx.InSoil(:,tix);

%--> reallocate to deeper layers
for sl  =   2:size(s.w.wSoil,2)
  ip                =   min(s.wd.p_wSoilBase_wSat(:,sl)  - s.w.wSoil(:,sl), s.wd.WBP);
  s.w.wSoil(:,sl)   =	  s.w.wSoil(:,sl) + ip;
  s.wd.WBP          =   s.wd.WBP - ip;
end

end

function [f,fe,fx,s,d,p] = dyna_roSat_BergstroemLinMixVegFr(f,fe,fx,s,d,p,info,tix)
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
%
% Versions:
%   - 1.0 on 18.11.2019 (ttraut): cleaned up the code
%%
% #########################################################################

tmp_smaxVeg   = p.roSat.smax1 + p.roSat.smax2;
tmp_SoilTotal = sum(s.w.wSoil, 2);
% calculate land runoff from incoming water and current soil moisture
tmp_InfExFrac = min(exp(p.roSat.berg(:,tix) .* log(tmp_SoilTotal  ./ tmp_smaxVeg)),1);
fx.roSat(:,tix)  = s.wd.WBP .* tmp_InfExFrac;


% original formula:
% fx.roInt(:,tix)  = (f.Rain(:,tix)+fx.snowMelt(:,tix)) .* (s.w.wSoil./p.roSat.smax).^p.roSat.berg;

% update water balance
s.wd.WBP        = s.wd.WBP - fx.roSat(:,tix);

% update soil moisture for 1st layer
fx.InSoil(:,tix) = min(p.roSat.smax1 - s.w.wSoil(:,1), s.wd.WBP);
s.w.wSoil(:,1)    = s.w.wSoil(:,1) + fx.InSoil(:,tix);

s.wd.WBP    = s.wd.WBP - fx.InSoil(:,tix);

% for deeper layers
for sl=2:size(s.w.wSoil,2)
  ip = min(p.roSat.smax2  - s.w.wSoil(:,sl), s.wd.WBP);
  s.w.wSoil(:,sl) =  s.w.wSoil(:,sl) + ip;
  s.wd.WBP = s.wd.WBP - ip;
end


end

function [f,fe,fx,s,d,p] = dyna_roSat_BergstroemLinMixVegFr(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculates land surface runoff and infiltration to different soil layers
%
% Inputs:
%   - p.roSat.berg       : shape parameter of runoff-infiltration curve []
%
% Outputs:
%   - fx.roSat : runoff from land [mm/time]
%
% Modifies:
%   - s.wd.WBP     : water balance pool [mm]
%
%
% References:
%   - Bergström, S. (1992). The HBV model–its structure and applications. SMHI.
%
% Created by:
%   - Tina Trautmann (ttraut)
%   - 1.1 on 27.11.2019: skoirala: changed to handle any number of soil layers
%
% Versions:
%   - 1.0 on 18.11.2019 (ttraut): cleaned up the code
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
tmp_smaxVeg         =   sum(s.wd.p_wSoilBase_wSat,2);
tmp_SoilTotal       =   sum(s.w.wSoil, 2);

%--> get the berg parameters according the vegetation fraction
p.roSat.berg        =   p.roSat.berg_scaleV .* s.cd.vegFrac + p.roSat.berg_scaleS .* (1-s.cd.vegFrac);
p.roSat.berg        =   max(0.1, p.roSat.berg); % do this?

%--> calculate land runoff from incoming water and current soil moisture
tmp_SatExFrac       =   min(exp(p.roSat.berg .* log(tmp_SoilTotal  ./ tmp_smaxVeg)),1);
fx.roSat(:,tix)     =   s.wd.WBP .* tmp_SatExFrac;

%--> update water balance
s.wd.WBP            =   s.wd.WBP - fx.roSat(:,tix);

end

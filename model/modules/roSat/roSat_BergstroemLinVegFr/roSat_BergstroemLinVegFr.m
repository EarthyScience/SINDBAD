function [f,fe,fx,s,d,p] = roSat_BergstroemLinVegFr(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculates land surface runoff and infiltration to different soil layers
% using 
%
% Inputs:
%   - s.cd.vegFrac       : vegetation fraction
%	- p.roSat.berg_scale : scalar for s.cd.vegFrac to defineshape parameter of runoff-infiltration curve []
%   - p.roSat.smax2      : maximum water capacity of second soil layer  [mm]
%   - p.roSat.smax1      : maximum water capacity of first soil layer  [mm]
%
% Outputs:
%   - fx.roSat : runoff from land [mm/time]
%   - s.wd.p_roSat_berg : scaled berg parameter
%
% Modifies:
%   - s.wd.WBP     : water balance pool [mm]
%
% References:
%   - Bergström, S. (1992). The HBV model–its structure and applications. SMHI.
%
% Created by:
%   - Tina Trautmann (ttraut)
%
% Versions:
%   - 1.2 on 10.02.2020 (ttraut): modyfying variable names to match the new SINDBAD version
%   - 1.1 on 27.11.2019 (skoirala): changed to handle any number of soil layers
%   - 1.0 on 18.11.2019 (ttraut): cleaned up the code
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
tmp_smaxVeg         =   sum(s.wd.p_wSoilBase_wSat,2);
tmp_SoilTotal       =   sum(s.w.wSoil, 2);

%--> get the berg parameters according the vegetation fraction
s.wd.p_roSat_berg    =   max(0.1, p.roSat.berg_scale  .* s.cd.vegFrac); % do this?

%--> calculate land runoff from incoming water and current soil moisture
tmp_SatExFrac       =   min(exp(s.wd.p_roSat_berg  .* log(tmp_SoilTotal  ./ tmp_smaxVeg)),1);
fx.roSat(:,tix)     =   s.wd.WBP .* tmp_SatExFrac;

%--> update water balance pool
s.wd.WBP            =   s.wd.WBP - fx.roSat(:,tix);

end
